#!/usr/bin/env bash
set -euo pipefail

target_hostname=""
target_destination=""
target_user="root"
ssh_key=""
remote_passwd="nixos"
# Create a temp directory for generated host keys
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
	rm -rf "$temp"
}
trap cleanup exit

# help function
help_and_exit() {
	echo "remotely installs nixos on a target machine using this nix-config."
	echo "usage: $0 -n=<target_hostname> -d=<target_destination> -k=<ssh_key> [options]"
	echo "required:"
	echo "  -n=<target_hostname>      specify target_hostname of the target host to deploy the nixos config on."
	echo "  -d=<target_destination>   specify ip or url to the target host."
	echo "  -k=<ssh_key>       		    specify the full path to the ssh_key you'll use for remote access to the"
	echo "														 target during install process."
	echo "               							Example: -k=/home/ta/.ssh/my_ssh_key"
	echo ""
	echo "options:"
	echo "  -u=<target_user>  				specify target_user with sudo access. nix-config will be cloned to their home."
	echo "                              Default='root'."
	echo "  -p=<remote_passwd>        Specify a password for target machine user. This is temporary until install is complete."
	echo "                              Default='nixos'."
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
	-h | --help) help_and_exit ;;
	*)
		echo "Invalid option detected."
		help_and_exit
		;;
	esac
	shift
done

# Validate required options
if [ -z "${target_hostname}" ] || [ -z "${target_destination}" || [ -z "${ssh_key}" ]; then
	echo "Error: -n -d and -k are required"
	help_and_exit
fi

echo "Installing NixOS on remote host $target_hostname at $target_destination"

echo "Adding installer ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
ssh-keyscan $target_destination >>~/.ssh/known_hosts

echo "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Generate host keys without a passphrase
ssh-keygen -t ed25519 -f $temp/etc/ssh/ssh_host_ed25519_key -C $target_user@$target_hostname -N ""

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

echo "Generating an age key based on the new ssh_host_ed25519_key."

age_key=$(nix-shell -p ssh-to-age --run "cat $temp/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age")

if grep -qv '^age1' <<<"$age_key"; then
	echo "The result from generated age key does not match the expected format."
	echo "Result: $age_key"
	echo "Expected format: age10000000000000000000000000000000000000000000000000000000000"
	exit 1
else
	echo "$age_key"
fi

echo "Updating nix-secrets/.sops.yaml"

# The spacing here MUST match that of the .sops.yaml file you are formatting.
sops_str1="\    - &$target_hostname $age_key"
sops_str2="\          - *$target_hostname"

sed -i "/&hosts:/ a\
$sops_str1" ../../nix-secrets/.sops.yaml

sed -i "/age:/ a\
$sops_str2" ../../nix-secrets/.sops.yaml

echo "Updating nix-secrets/.sops.yaml"
sops --config ../../nix-secrets/.sops.yaml updatekeys -y ../../nix-secrets/secrets.yaml

echo "Pushing new host key to secrets"
cd ../../nix-secrets
git commit -am "feat: added key for $target_hostname"
git push

echo "Updating flake lock on source machine with new .sops.yaml info"
cd ../nix-config
nix flake lock --update-input mysecrets

## clear the existing host entry for the target to prevent mismatch between the default keys and the new host keys we generated
cd nixos-installer
sed -i "/$target_destination/ d" ~/.ssh/known_hosts

# Execute installation
# nixos-anywhere --extra-files "$temp" --flake '.#your-host' root@yourip
#SHELL=/bin/sh nix run github:nix-community/nixos-anywhere --\
#--flake .#$target_hostname \
#root@$target_destination

SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --flake .#$target_hostname $target_user@$target_destination -i $ssh_key

echo "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
ssh-keyscan $target_destination >>~/.ssh/known_hosts

# connect to the new install and generate a hardware config based on the work declared by disko
ssh -i $ssh_key $target_user@$target_destination "nixos-generate-config"

# copy the target hardware config to nix-config on the source
scp -i $ssh_key $target_user@$target_destination:/etc/nixos/hardware-configuration.nix ../hosts/$target_hostname/hardware-configuration.nix

git commit -am "feat: add hardware config for $target_hostname"
git push

echo "Copying nix-config on $target_hostname"

# NOTE For the --filter switch, there's a space before ".gitignore", which tells rsync to do a directory merge with .gitignore files and have them exclude per git's rules.
rsync -rv --filter=':- .gitignore' ../* $target_user@$target_destination:nix-config/
#scp -r -i $ssh_key ../* $target_user@$target_destination:nix-config/
#ssh $target_user@$target_destination -i $ssh_key "git clone https://github.com/EmergentMind/nix-config.git"

#TODO prune all previous generations

echo ""
echo "NixOS installed and nix-config cloned."
echo "Sign into $target_hostname and run the following command from ~/nix-config"
echo "sudo nixos-rebuild switch --flake .#target_hostname"
