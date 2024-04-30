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
	echo "Error: -n -d and -k are required"
	help_and_exit
fi

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

echo "Installing NixOS on remote host $target_hostname at $target_destination"
# We don't want to use $target_user here because the iso only provides a root user
#SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --flake .#$target_hostname root@$target_destination -i $ssh_key --ssh-option "UserKnownHostsFile=/dev/null"
SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake .#$target_hostname $target_user@$target_destination -i $ssh_key --ssh-option "UserKnownHostsFile=/dev/null"

echo "Connect to $target_destination and generate a hardware config based on the work declared by disko"
ssh -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $target_user@$target_destination "nixos-generate-config"

echo "Copy the target hardware config to nix-config on the source"
scp -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $target_user@$target_destination:/etc/nixos/hardware-configuration.nix ../hosts/$target_hostname/hardware-configuration.nix

echo "Copying nix-config on $target_hostname"
# NOTE For the --filter switch, there's a space before ".gitignore", which tells rsync to do a directory merge with .gitignore files and have them exclude per git's rules.
rsync -av -e "ssh -l root -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --filter=':- .gitignore' ../* $target_user@$target_destination:nix-config/

echo "Updating nix-secrets/.sops.yaml"
#cd ../../nix-secrets

SOPS_FILE="../../nix-secrets/.sops.yaml"
sed -i "{
	# Remove any * and & entries for this host
	/[*&]$target_hostname/ d;
	# Inject a new age: entry
	# n matches the first line following age: and p prints it, then we transform it while reusing the spacing
	/age:/{n; p; s/\(.*- \*\).*/\1$target_hostname/};
	# Inject a new hosts: entry
	/&hosts:/{n; p; s/\(.*- &\).*/\1$target_hostname $age_key/}
	}" $SOPS_FILE

echo "Updating nix-secrets/.sops.yaml"
sops --config $SOPS_FILE updatekeys -y ../../nix-secrets/secrets.yaml

echo "Pushing new host key to secrets"
cd ../../nix-secrets

git commit -am "feat: added key for $target_hostname"
git push

echo "Updating flake lock on source machine with new .sops.yaml info"
cd ../nix-config
nix flake lock --update-input nix-secrets

echo "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
ssh-keyscan $target_destination >>~/.ssh/known_hosts

#TODO prune all previous generations

#git commit -am "feat: add hardware config for $target_hostname"
#git push

echo ""
echo "NixOS installed and nix-config cloned."
echo ""
echo "Preparing for nix-secrets input"
scp -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ta/.ssh/id_manu* $target_user@$target_destination:.ssh/

echo "Adding gitlab.com fingerprint"
ssh -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $target_user@$target_destination "ssh-keyscan gitlab.com >>~/.ssh/known_hosts"

# Need to build manually until I'm running nix on ghost or genoa because agent forwarding isn't setup
echo -e "Prepped for rebuild\n\nssh into the box and run 'nixos-rebuild switch --flake nix-config/#<hostname>"

#echo "Building nix-config"
#ssh -i $ssh_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $target_user@$target_destination "nixos-rebuild switch --flake nix-config/#$target_hostname"
