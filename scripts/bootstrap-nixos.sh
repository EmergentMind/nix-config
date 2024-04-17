#!/usr/bin/env bash
set -eo pipefail

target_hostname=""
target_destination=""
target_user="root"
ssh_key=""
remote_passwd="nixos"
persist_dir=""
# Create a temp directory for generated host keys
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
	rm -rf "$temp"
}
trap cleanup exit

# terminal output coloring
function red() {
	echo -e "\x1B[31m[!] $1 \x1B[0m"
	if [ -n "${2}" ]; then
		echo -e "\x1B[31m[!] $($2) \x1B[0m"
	fi
}
function green() {
	echo -e "\x1B[32m[+] $1 \x1B[0m"
	if [ -n "${2}" ]; then
		echo -e "\x1B[32m[+] $($2) \x1B[0m"
	fi
}

function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

# confirmation helper
function yes_or_no {
	while true; do
		read -rp "$* [y/n]: " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*)
			echo "Aborted"
			return 1
			;;
		esac
	done
}

# help function
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
	echo "                            Example: -k=/home/ta/.ssh/my_ssh_key"
	echo
	echo "OPTIONS:"
	echo "  -u=<target_user>          specify target_user with sudo access. nix-config will be cloned to their home."
	echo "                            Default='ta'."
	echo "  -p=<remote_passwd>        Specify a password for target machine user. This is temporary until install is complete."
	echo "                            Default='temp'."
	echo "  --impermanence            Use this flag if the target machine has impermanence enabled. WARNING: Assumes /persist path."
	echo "  --debug                   Enable debug mode."
	echo "  -h | --help               Print this help."
	exit 0
}

# Handle options
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

# Validate required options
if [ -z "${target_hostname}" ] || [ -z "${target_destination}" ] || [ -z "${ssh_key}" ]; then
	red "ERROR: -n, -d, and -k are all required"
	echo
	help_and_exit
fi

green "Installing NixOS on remote host $target_hostname at $target_destination"

###
# nixos-anywhere extra-files generation
###
# FIXME: Add a flag to detect if there's impermanence, and only then add /persist
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

# If we are doing a fresh install, the existing hardware-configuration.nix will conflict with our disko, so clobber
#echo "{}" >../hosts/$target_hostname/hardware-configuration.nix
# disko expects a passphrase on /tmp/disko-password, so we set it for now and will update the passphrase later
ssh -i "$ssh_key" "$target_user"@"$target_destination" "/bin/sh -c 'echo passphrase > /tmp/disko-password'"
# ssh -i $ssh_key $target_user@$target_destination "echo $remote_passwd > /tmp/disko-password"

# copy our repo there via rsync for speed
just sync "$target_user" "$target_destination"
ssh "$target_user"@"$target_destination" -i "$ssh_key" "nixos-generate-config --no-filesystems --root /mnt"
scp -i "$ssh_key" "$target_user"@"$target_destination":/mnt/etc/nixos/hardware-configuration.nix ../hosts/"$target_hostname"/hardware-configuration.nix
just sync "$target_user" "$target_destination"

# --extra-files here picks up the ssh host key we generated earlier and puts it onto the target machine
SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake .#"$target_hostname" "$target_user"@"$target_destination"
cd -

yes_or_no "Do you want to generate new age keys?" || exit 0

green "Generating an age key based on the new ssh_host_ed25519_key."

age_key=$(nix-shell -p ssh-to-age --run "cat $temp/$persist_dir/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age")

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

# FIXME: depending on the host I'll have to rekey other secrets
sops --config $SOPS_FILE updatekeys -y secrets.yaml

green "Pushing new host key to secrets"
git commit -am "feat: added key for $target_hostname"
git push

green "Updating flake lock on source machine with new .sops.yaml info"
cd -
nix flake lock --update-input nix-secrets

#git commit -am "feat: add hardware config for $target_hostname"
#git push

echo "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
ssh-keyscan "$target_destination" >>~/.ssh/known_hosts

echo "Adding ssh fingerprint for gitlab.com to ~/.ssh/known_hosts"
ssh -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $target_user@$target_destination "ssh-keyscan gitlab.com >>~/.ssh/known_hosts"

echo "Copying private key to /home/$target_user/.ssh on $target_destination for nix-secrets access on final build"
scp -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ta/.ssh/id_manu* $target_user@$target_destination:.ssh/

#TODO prune all previous generations

green "Building nix-config on $target_hostname"
# FIXME: This won't work until we have yubikey-passthrough working
#ssh -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $target_user@$target_destination "nixos-rebuild switch --flake nix-config/#$target_hostname"

echo
green "NixOS and minimal installed. Ready to rebuild using nix-config"
green "Sign into $target_hostname and run the following command from ~/nix-config"
green "nixos-rebuild switch --flake nix-config/#$target_hostname"
