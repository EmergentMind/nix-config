#!/usr/bin/env bash
set -eo pipefail

config_location="git://git@gitlab.com/emergentmind/nix-config.git"
target_hostname=""
target_destination=""
target_user="ta"
ssh_key=""
ssh_port="22"
remote_passwd="temp"
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
	while true; do
		read -rp "$* [y/n] (default: y): " yn
		yn=${yn:-y}
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		esac
	done
}

function help_and_exit() {
	echo
	echo "Remotely installs NixOS on a target machine using this nix-config."
	echo
	echo "USAGE: $0 -n=<target_hostname> -d=<target_destination> -k=<ssh_key> [OPTIONS]"
	echo
	echo "ARGS:"
	echo "  -n=<target_hostname>      specify target_hostname of the target host to deploy the nixos config on."
	echo "  -d=<target_destination>   specify ip or url to the target host."
	echo "  -k=<ssh_key>              specify the full path to the ssh_key you'll use for remote access to the"
	echo "                            target during install process."
	echo "                            Example: -k=/home/${target_user}/.ssh/my_ssh_key"
	echo
	echo "OPTIONS:"
	echo "  -u=<target_user>          specify target_user with sudo access. nix-config will be cloned to their home."
	echo "                            Default='${target_user}'."
	echo "  -p=<remote_passwd>        Specify a password for target machine user. This is temporary until install is complete."
	echo "                            Default='${remote_passwd}'."
	echo "  --port=<ssh_port>         specify the ssh port to use for remote access. Default=${ssh_port}."
	echo "  --impermanence            Use this flag if the target machine has impermanence enabled. WARNING: Assumes /persist path."
	echo "  --debug                   Enable debug mode."
	echo "  -h | --help               Print this help."
	exit 0
}

# Handle command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-n=*)
		target_hostname="${1#-n=}"
		;;
	-d=*)
		target_destination="${1#-d=}"
		;;
	-u=*)
		target_user="${1#-u=}"
		;;
	-k=*)
		ssh_key="${1#-k=}"
		;;
	-p=*)
		remote_passwd="${1#-p=}"
		;;
	--port=*)
		ssh_port="${1#--port=}"
		;;
	--temp-override=*)
		temp="${1#--temp-override=}"
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

function nixos_anywhere() {
	green "Installing NixOS on remote host $target_hostname at $target_destination"

	###
	# nixos-anywhere extra-files generation
	###
	green "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
	# Create the directory where sshd expects to find the host keys
	install -d -m755 "$temp/$persist_dir/etc/ssh"

	# Generate host keys without a passphrase
	ssh-keygen -t ed25519 -f "$temp/$persist_dir/etc/ssh/ssh_host_ed25519_key" -C "$target_user"@"$target_hostname" -N ""

	# Set the correct permissions so sshd will accept the key
	chmod 600 "$temp/$persist_dir/etc/ssh/ssh_host_ed25519_key"

	###
	# nixos-anywhere installation
	###
	cd nixos-installer

	# disko expects a passphrase on /tmp/disko-password, so we set it for now and will update the passphrase later
	green "Preparing a temporary password for disko."
	$ssh_cmd "/bin/sh -c 'echo passphrase > /tmp/disko-password'"

	# copy our repo there via rsync for speed
	green "Syncing nix-config to $target_hostname"
	just sync "$target_user" "$target_destination"
	$ssh_cmd "nixos-generate-config --no-filesystems --root /mnt"
	$scp_cmd "$target_user"@"$target_destination":/mnt/etc/nixos/hardware-configuration.nix ../hosts/"$target_hostname"/hardware-configuration.nix
	just sync "$target_user" "$target_destination"

	# --extra-files here picks up the ssh host key we generated earlier and puts it onto the target machine
	# FIXME: Double check that it will delete them?
	SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --ssh-port "$ssh_port" --extra-files "$temp" --flake .#"$target_hostname" "$target_user"@"$target_destination"

	echo "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
	# This will fail if we already know the host, but that's fine
	ssh-keyscan -p $ssh_port "$target_destination" >>~/.ssh/known_hosts || true

	# These might fail if /persist folder already exists
	# FIXME: Do we need this? I get errors:
	# /etc/tmpfiles.d/journal-nocow.conf:26: Failed to resolve specifier: uninitialized /etc/ detected, skipping.
	# And there is no /etc/machine-id after first rebuild...
	$ssh_cmd "cp /etc/machine-id /persist/etc/machine-id || true"
	$ssh_cmd "cp -R /etc/ssh/ /persist/etc/ssh/ || true"
	cd -
}

function generate_age_keys() {
	green "Generating an age key based on the new ssh_host_ed25519_key."

	target_key=$(ssh-keyscan -p $ssh_port -t ssh-ed25519 "$target_destination" 2>&1 | rg ssh-ed25519 | cut -f2- -d" ")
	age_key=$(nix shell nixpkgs#ssh-to-age.out -c sh -c "echo $target_key | ssh-to-age")

	if grep -qv '^age1' <<<"$age_key"; then
		echo "The result from generated age key does not match the expected format."
		echo "Result: $age_key"
		echo "Expected format: age10000000000000000000000000000000000000000000000000000000000"
		exit 1
	else
		echo "$age_key"
	fi

	green "Updating nix-secrets/.sops.yaml"
	cd ../nix-secrets

	SOPS_FILE=".sops.yaml"
	sed -i "{
	# Remove any * and & entries for this host
	/[*&]$target_hostname/ d;
	# Inject a new age: entry
	# n matches the first line following age: and p prints it, then we transform it while reusing the spacing
	/age:/{n; p; s/\(.*- \*\).*/\1$target_hostname/};
	# Inject a new hosts: entry
	/&hosts:/{n; p; s/\(.*- &\).*/\1$target_hostname $age_key/}
	}" $SOPS_FILE

	green "Updating nix-secrets/.sops.yaml"
	cd -
	just rekey

	green "Updating flake lock on source machine with new .sops.yaml info"
	nix flake lock --update-input nix-secrets
}

# Validate required options
if [ -z "${target_hostname}" ] || [ -z "${target_destination}" ] || [ -z "${ssh_key}" ]; then
	red "ERROR: -n, -d, and -k are all required"
	echo
	help_and_exit
fi

# Clear the keys, since they should be newly generated for the iso
green "Wiping known_hosts of $target_destination"
sed -i "/$target_hostname/d; /$target_destination/d" ~/.ssh/known_hosts

ssh_cmd="ssh -oport=${ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $ssh_key $target_user@$target_destination"
scp_cmd="scp -oport=${ssh_port} -o StrictHostKeyChecking=no -i $ssh_key"

if yes_or_no "Do you want to run nixos-anywhere installation"; then
	nixos_anywhere
fi

if yes_or_no "Do you want to run age key generation?"; then
	generate_age_keys
fi

if [ "$target_user" == "root" ]; then
	home_path="/root"
else
	home_path="/home/$target_user"
fi
$ssh_cmd "mkdir -p $home_path/.ssh/; ssh-keyscan -t ssh-ed25519 gitlab.com github.com >>$home_path/.ssh/known_hosts"

# FIXME: Add some sort of key access from the target to download the config (if it's a cloud system)

if yes_or_no "Do you want to clone and rebuild immediately? (requires yubikey-agent)"; then
	green "Cloning nix-config on $target_hostname"
	# We purpusefully let the below fail if we are doing a re-build after failure and we synced the repo to the host
	# for testing. Otherwise it would fail because the folder already exists.
	$ssh_cmd "git clone ssh+$config_location || true"
	# If we used just sync, the ownership will be our local user, but we may be running as root, so git will fail.
	$ssh_cmd "chown -R $target_user:$target_user nix-config"
	green "Rebuilding nix-config on $target_hostname"
	$ssh_cmd "cd nix-config && just rebuild"

else
	echo
	green "NixOS installed"
	echo "Post-install instructions:"
	echo "Sign into $target_hostname and run the following commands from ~/nix-config"
	echo "git clone ssh+$config_location && cd nix-config"
	echo "just rebuild"
fi

#TODO prune all previous generations?

green "All done!"
