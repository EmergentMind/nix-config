#!/usr/bin/env bash
set -eo pipefail

# User variables
target_hostname=""
target_destination=""
target_user="ta"
ssh_key=""
ssh_port="22"
persist_dir=""
# Create a temp directory for generated host keys
temp=$(mktemp -d)

# Cleanup temporary directory on exit
function cleanup() {
	rm -rf "$temp"
}
trap cleanup exit

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
function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

function yes_or_no() {
	echo -en "\x1B[32m[+] $* [y/n] (default: y): \x1B[0m"
	while true; do
		read -rp "" yn
		yn=${yn:-y}
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		esac
	done
}

function sync() {
	# $1 = user, $2 = source, $3 = destination
	rsync -av --filter=':- .gitignore' -e "ssh -l $1 -oport=${ssh_port}" $2 $1@${target_destination}:
}

function help_and_exit() {
	echo
	echo "Remotely installs NixOS on a target machine using this nix-config."
	echo
	echo "USAGE: $0 -n <target_hostname> -d <target_destination> -k <ssh_key> [OPTIONS]"
	echo
	echo "ARGS:"
	echo "  -n <target_hostname>      specify target_hostname of the target host to deploy the nixos config on."
	echo "  -d <target_destination>   specify ip or url to the target host."
	echo "  -k <ssh_key>              specify the full path to the ssh_key you'll use for remote access to the"
	echo "                            target during install process."
	echo "                            Example: -k /home/${target_user}/.ssh/my_ssh_key"
	echo
	echo "OPTIONS:"
	echo "  -u <target_user>          specify target_user with sudo access. nix-config will be cloned to their home."
	echo "                            Default='${target_user}'."
	echo "  --port <ssh_port>         specify the ssh port to use for remote access. Default=${ssh_port}."
	echo "  --impermanence            Use this flag if the target machine has impermanence enabled. WARNING: Assumes /persist path."
	echo "  --debug                   Enable debug mode."
	echo "  -h | --help               Print this help."
	exit 0
}

# Handle command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-n)
		shift
		target_hostname=$1
		;;
	-d)
		shift
		target_destination=$1
		;;
	-u)
		shift
		target_user=$1
		;;
	-k)
		shift
		ssh_key=$1
		;;
	--port)
		shift
		ssh_port=$1
		;;
	--temp-override)
		shift
		temp=$1
		;;
	--impermanence)
		persist_dir="/persist"
		;;
	--debug)
		set -x
		;;
	-h | --help) help_and_exit ;;
	*)
		echo "Invalid option detected."
		help_and_exit
		;;
	esac
	shift
done

# SSH commands
ssh_cmd="ssh -oport=${ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $ssh_key -t $target_user@$target_destination"
ssh_root_cmd=$(echo "$ssh_cmd" | sed "s|${target_user}@|root@|") # uses @ in the sed switch to avoid it triggering on the $ssh_key value
scp_cmd="scp -oport=${ssh_port} -o StrictHostKeyChecking=no -i $ssh_key"

git_root=$(git rev-parse --show-toplevel)

function nixos_anywhere() {
	# Clear the keys, since they should be newly generated for the iso
	green "Wiping known_hosts of $target_destination"
	sed -i "/$target_hostname/d; /$target_destination/d" ~/.ssh/known_hosts

	green "Installing NixOS on remote host $target_hostname at $target_destination"

	###
	# nixos-anywhere extra-files generation
	###
	green "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
	# Create the directory where sshd expects to find the host keys
	install -d -m755 "$temp/$persist_dir/etc/ssh"

	# Generate host ssh key pair without a passphrase
	ssh-keygen -t ed25519 -f "$temp/$persist_dir/etc/ssh/ssh_host_ed25519_key" -C root@"$target_hostname" -N ""

	# Set the correct permissions so sshd will accept the key
	chmod 600 "$temp/$persist_dir/etc/ssh/ssh_host_ed25519_key"

	echo "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
	# This will fail if we already know the host, but that's fine
	ssh-keyscan -p "$ssh_port" "$target_destination" >>~/.ssh/known_hosts || true

	###
	# nixos-anywhere installation
	###
	cd nixos-installer

	# when using luks, disko expects a passphrase on /tmp/disko-password, so we set it for now and will update the passphrase later
	# via the config
	green "Preparing a temporary password for disko."
	$ssh_root_cmd "/bin/sh -c 'echo passphrase > /tmp/disko-password'"

	green "Generating hardware-config.nix for $target_hostname and adding it to the nix-config."
	$ssh_root_cmd "nixos-generate-config --no-filesystems --root /mnt"
	$scp_cmd root@"$target_destination":/mnt/etc/nixos/hardware-configuration.nix "${git_root}"/hosts/"$target_hostname"/hardware-configuration.nix

	# --extra-files here picks up the ssh host key we generated earlier and puts it onto the target machine
	SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --ssh-port "$ssh_port" --extra-files "$temp" --flake .#"$target_hostname" root@"$target_destination"

	echo "Updating ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
	ssh-keyscan -p "$ssh_port" "$target_destination" >>~/.ssh/known_hosts || true

	if [ -n "$persist_dir" ]; then
		$ssh_root_cmd "cp /etc/machine-id $persist_dir/etc/machine-id || true"
		$ssh_root_cmd "cp -R /etc/ssh/ $persist_dir/etc/ssh/ || true"
	fi
	cd -
}

# args: $1 = key name, $2 = key type, $3 key
function update_sops_file() {
	key_name=$1
	key_type=$2
	key=$3

	if [ ! "$key_type" == "hosts" ] && [ ! "$key_type" == "users" ]; then
		red "Invalid key type passed to update_sops_file. Must be either 'hosts' or 'users'."
		exit 1
	fi
	cd "${git_root}"/../nix-secrets

	SOPS_FILE=".sops.yaml"
	sed -i "{
	# Remove any * and & entries for this host
	/[*&]$key_name/ d;
	# Inject a new age: entry
	# n matches the first line following age: and p prints it, then we transform it while reusing the spacing
	/age:/{n; p; s/\(.*- \*\).*/\1$key_name/};
	# Inject a new hosts or user: entry
	/&$key_type:/{n; p; s/\(.*- &\).*/\1$key_name $key/}
	}" $SOPS_FILE
	green "Updating nix-secrets/.sops.yaml"
	cd -
}

function generate_host_age_key() {
	green "Generating an age key based on the new ssh_host_ed25519_key."

	target_key=$(
		ssh-keyscan -p "$ssh_port" -t ssh-ed25519 "$target_destination" 2>&1 |
			grep ssh-ed25519 |
			cut -f2- -d" " ||
			(
				red "Failed to get ssh key. Host down?"
				exit 1
			)
	)
	host_age_key=$(nix shell nixpkgs#ssh-to-age.out -c sh -c "echo $target_key | ssh-to-age")

	if grep -qv '^age1' <<<"$host_age_key"; then
		red "The result from generated age key does not match the expected format."
		yellow "Result: $host_age_key"
		yellow "Expected format: age10000000000000000000000000000000000000000000000000000000000"
		exit 1
	else
		echo "$host_age_key"
	fi

	green "Updating nix-secrets/.sops.yaml"
	update_sops_file "$target_hostname" "hosts" "$host_age_key"
}

function generate_user_age_key() {
	echo "First checking if ${target_hostname} age key already exists"
	secret_file="${git_root}"/../nix-secrets/secrets.yaml
	if ! sops -d --extract '["user_age_keys"]' "$secret_file" >/dev/null ||
		! sops -d --extract "[\"user_age_keys\"][\"${target_hostname}\"]" "$secret_file" >/dev/null 2>&1; then
		echo "Age key does not exist. Generating."
		user_age_key=$(nix shell nixpkgs#age -c "age-keygen")
		readarray -t entries <<<"$user_age_key"
		secret_key=${entries[2]}
		public_key=$(echo "${entries[1]}" | rg key: | cut -f2 -d: | xargs)
		key_name="${target_user}_${target_hostname}"
		# shellcheck disable=SC2116,SC2086
		sops --set "$(echo '["user_age_keys"]["'${key_name}'"] "'$secret_key'"')" "$secret_file"
		update_sops_file "$key_name" "users" "$public_key"
	else
		echo "Age key already exists for ${target_hostname}"
	fi
}

# Validate required options
# FIXME: The ssh key and destination aren't required if only rekeying, so could be moved into specific sections?
if [ -z "${target_hostname}" ] || [ -z "${target_destination}" ] || [ -z "${ssh_key}" ]; then
	red "ERROR: -n, -d, and -k are all required"
	echo
	help_and_exit
fi

if yes_or_no "Run nixos-anywhere installation?"; then
	nixos_anywhere
fi

if yes_or_no "Generate host (ssh-based) age key?"; then
	generate_host_age_key
	updated_age_keys=1
fi

if yes_or_no "Generate user age key?"; then
	generate_user_age_key
	updated_age_keys=1
fi

if [[ $updated_age_keys == 1 ]]; then
	# Since we may update the sops.yaml file twice above, only rekey once at the end
	just rekey
	green "Updating flake input to pick up new .sops.yaml"
	nix flake lock --update-input nix-secrets
fi

if yes_or_no "Add ssh host fingerprints for git{lab,hub}? If this is the first time running this script on $target_hostname, this will be required for the following steps?"; then
	if [ "$target_user" == "root" ]; then
		home_path="/root"
	else
		home_path="/home/$target_user"
	fi
	green "Adding ssh host fingerprints for git{lab,hub}"
	$ssh_cmd "mkdir -p $home_path/.ssh/; ssh-keyscan -t ssh-ed25519 gitlab.com github.com >>$home_path/.ssh/known_hosts"
fi

if yes_or_no "Do you want to copy your full nix-config and nix-secrets to $target_hostname?"; then
	green "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
	ssh-keyscan -p "$ssh_port" "$target_destination" >>~/.ssh/known_hosts || true
	green "Copying full nix-config to $target_hostname"
	sync "$target_user" "${git_root}"/../nix-config
	green "Copying full nix-secrets to $target_hostname"
	sync "$target_user" "${git_root}"/../nix-secrets

if yes_or_no "Do you want to rebuild immediately?"; then
	green "Rebuilding nix-config on $target_hostname"
	#FIXME there are still a gitlab fingerprint request happening during the rebuild
	#$ssh_cmd -oForwardAgent=yes "cd nix-config && sudo nixos-rebuild --show-trace --flake .#$target_hostname" switch"
	$ssh_cmd -oForwardAgent=yes "cd nix-config && just rebuild"
fi
else
	echo
	green "NixOS was successfully installed!"
	echo "Post-install config build instructions:"
	echo "To copy nix-config from this machine to the $target_hostname, run the following command from ~/nix-config"
	echo "just sync $target_user $target_destination"
	echo "To rebuild, sign into $target_hostname and run the following command from ~/nix-config"
	echo "cd nix-config"
	echo "just rebuild"
	echo
fi

if yes_or_no "You can now commit and push the nix-config, which includes the hardware-configuration.nix for $target_hostname?"; then
	(pre-commit run --all-files 2>/dev/null || true) &&
		git add "$git_root/hosts/$target_hostname/hardware-configuration.nix" && (git commit -m "feat: hardware-configuration.nix for $target_hostname" || true) && git push
fi

#TODO prune all previous generations?

green "Success!"
green "If you are using a disko config with luks partitions, update luks to use non-temporary credentials."
