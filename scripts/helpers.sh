#!/usr/bin/env bash
set -eo pipefail

### UX helpers

function red() {
	echo -e "\x1B[31m[!] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[31m[!] $($2) \x1B[0m"
	fi
}

function green() {
	echo -e "\x1B[32m[+] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[32m[+] $($2) \x1B[0m"
	fi
}

function blue() {
	echo -e "\x1B[34m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[34m[*] $($2) \x1B[0m"
	fi
}

function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

# Ask yes or no, with yes being the default
function yes_or_no() {
	echo -en "\x1B[34m[?] $* [y/n] (default: y): \x1B[0m"
	while true; do
		read -rp "" yn
		yn=${yn:-y}
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		esac
	done
}

# Ask yes or no, with no being the default
function no_or_yes() {
	echo -en "\x1B[34m[?] $* [y/n] (default: n): \x1B[0m"
	while true; do
		read -rp "" yn
		yn=${yn:-n}
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		esac
	done
}

### SOPS helpers
nix_secrets_dir=${NIX_SECRETS_DIR:-"$(dirname "${BASH_SOURCE[0]}")/../../nix-secrets"}
SOPS_FILE="${nix_secrets_dir}/.sops.yaml"

# Updates the .sops.yaml file with a new host or user age key.
function sops_update_age_key() {
	field="$1"
	keyname="$2"
	key="$3"

	if [ ! "$field" == "hosts" ] && [ ! "$field" == "users" ]; then
		red "Invalid field passed to sops_update_age_key. Must be either 'hosts' or 'users'."
		exit 1
	fi

	if [[ -n $(yq ".keys.${field}[] | select(anchor == \"$keyname\")" "${SOPS_FILE}") ]]; then
		green "Updating existing ${keyname} key"
		yq -i "(.keys.${field}[] | select(anchor == \"$keyname\")) = \"$key\"" "$SOPS_FILE"
	else
		green "Adding new ${keyname} key"
		yq -i ".keys.$field += [\"$key\"] | .keys.${field}[-1] anchor = \"$keyname\"" "$SOPS_FILE"
	fi
}

# Adds the user and host to the shared.yaml creation rules
function sops_add_shared_creation_rules() {
	u="\"$1_$2\"" # quoted user_host for yaml
	h="\"$2\""    # quoted hostname for yaml

	shared_selector='.creation_rules[] | select(.path_regex == "shared\.yaml$")'
	if [[ -n $(yq "$shared_selector" "${SOPS_FILE}") ]]; then
		echo "BEFORE"
		cat "${SOPS_FILE}"
		if [[ -z $(yq "$shared_selector.key_groups[].age[] | select(alias == $h)" "${SOPS_FILE}") ]]; then
			green "Adding $u and $h to shared.yaml rule"
			# NOTE: Split on purpose to avoid weird file corruption
			yq -i "($shared_selector).key_groups[].age += [$u, $h]" "$SOPS_FILE"
			yq -i "($shared_selector).key_groups[].age[-2] alias = $u" "$SOPS_FILE"
			yq -i "($shared_selector).key_groups[].age[-1] alias = $h" "$SOPS_FILE"
		fi
	else
		red "shared.yaml rule not found"
	fi
}

# Adds the user and host to the host.yaml creation rules
function sops_add_host_creation_rules() {
	host="$2"                     # hostname for selector
	h="\"$2\""                    # quoted hostname for yaml
	u="\"$1_$2\""                 # quoted user_host for yaml
	w="\"$(whoami)_$(hostname)\"" # quoted whoami_hostname for yaml
	n="\"$(hostname)\""           # quoted hostname for yaml

	host_selector=".creation_rules[] | select(.path_regex | contains(\"${host}\.yaml\"))"
	if [[ -z $(yq "$host_selector" "${SOPS_FILE}") ]]; then
		green "Adding new host file creation rule"
		yq -i ".creation_rules += {\"path_regex\": \"${host}\\.yaml$\", \"key_groups\": [{\"age\": [$u, $h]}]}" "$SOPS_FILE"
		# Add aliases one by one
		yq -i "($host_selector).key_groups[].age[0] alias = $u" "$SOPS_FILE"
		yq -i "($host_selector).key_groups[].age[1] alias = $h" "$SOPS_FILE"
		yq -i "($host_selector).key_groups[].age[2] alias = $w" "$SOPS_FILE"
		yq -i "($host_selector).key_groups[].age[3] alias = $n" "$SOPS_FILE"
	fi
}

# Adds the user and host to the shared.yaml and host.yaml creation rules
function sops_add_creation_rules() {
	user="$1"
	host="$2"

	sops_add_shared_creation_rules "$user" "$host"
	sops_add_host_creation_rules "$user" "$host"
}

age_secret_key=""
# Generate a user age key, update the .sops.yaml entries, and return the key in age_secret_key
# args: user, hostname
function sops_generate_user_age_key() {
	target_user="$1"
	target_hostname="$2"
	key_name="${target_user}_${target_hostname}"
	green "Age key does not exist. Generating."
	user_age_key=$(age-keygen)
	readarray -t entries <<<"$user_age_key"
	age_secret_key=${entries[2]}
	public_key=$(echo "${entries[1]}" | rg key: | cut -f2 -d: | xargs)
	green "Generated age key for ${key_name}"
	# Place the anchors into .sops.yaml so other commands can reference them
	sops_update_age_key "users" "$key_name" "$public_key"
	sops_add_creation_rules "${target_user}" "${target_hostname}"

	# "return" key so it can be used by caller
	export age_secret_key
}

function sops_setup_user_age_key() {
	target_user="$1"
	target_hostname="$2"

	secret_file="${nix_secrets_dir}/sops/${target_hostname}.yaml"
	config="${nix_secrets_dir}/.sops.yaml"
	# If the secret file doesn't exist, it means we're generating a new user key as well
	if [ ! -f "$secret_file" ]; then
		green "Host secret file does not exist. Creating $secret_file"
		sops_generate_user_age_key "${target_user}" "${target_hostname}"
		mkdir -p "$(dirname "$secret_file")"
		echo "{}" >"$secret_file"
		sops --config "$config" -e "$secret_file" >"$secret_file.enc"
		mv "$secret_file.enc" "$secret_file"
	fi
	if ! sops --config "$config" -d --extract '["keys]["age"]' "$secret_file" >/dev/null 2>&1; then
		if [ -z "$age_secret_key" ]; then
			sops_generate_user_age_key "${target_user}" "${target_hostname}"
		fi
		# shellcheck disable=SC2116,SC2086
		sops --config "$config" --set "$(echo '["keys"]["age"] "'$age_secret_key'"')" "$secret_file"
	else
		green "Age key already exists for ${target_hostname}"
	fi
}
