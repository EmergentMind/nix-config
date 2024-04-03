#!/usr/bin/env bash
set -euo pipefail

target_hostname=""
target_destination=""
ssh_key=""
remote_passwd="root"
# Create a temp directory for generated host keys
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
	rm -rf "$temp"
}
trap cleanup EXIT

# Help function
help_and_exit() {
	echo "Remotely installs NixOS on a target machine using this nix-config."
	echo "Usage: $0 -n=<target_hostname> -d=<target_destination> -k=<ssh_key> [options]"
	echo "Required:"
	echo "  -n=<target_hostname>      Specify target_hostname of the target host to deploy the NixOS config on."
	echo "  -d=<target_destination>   Specify ip or url to the target host."
	echo "  -k=<ssh_key>           Specify the full path to the public ssh_key you'll use for subsequent remote access ot the target host."
	echo "                     Example: -k=/home/ta/.ssh/my_ssh_key.pub"
	echo ""
	echo "options:"
	echo "  -p=<remote_passwd>        Specify a password for target machine root user. This is temporary until install is complete."
	echo "                              Default='root'."
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
if [ -z "${target_hostname}" ] || [ -z "${target_destination}" ]; then
	echo "Error: both -n and -d are required"
	help_and_exit
fi

# Start the install process
echo "Installing NixOS on remote host $target_hostname at $target_destination"

echo "Adding installer ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
ssh-keyscan $target_destination >>~/.ssh/known_hosts

echo "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Generate host keys without a passphrase
ssh-keygen -t ed25519 -f $temp/etc/ssh/ssh_host_ed25519_key -C root@$target_hostname -N ""

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

# update sopskeys
echo "Updating nix-secrets/.sops.yaml"
sops --config ../../nix-secrets/.sops.yaml updatekeys -y ../../nix-secrets/secrets.yaml

# push the changes to nix-secrets
cd ../../nix-secrets
git commit -am "feat: added key for $target_hostname"
git push
# come back to nixos-installer
cd -

# change to root nix-config directory to update flake inputs with the updated secrets
echo "updating flake lock on source machine with new .sops.yaml info"
cd ..
nix flake lock --update-input mysecrets

# comeback to nixos installer
cd -
# clear the existing host entry for the target to prevent mismatch between the default keys and the new host keys we generated
sed -i "/$target_destination/ d" ~/.ssh/known_hosts

# Execute installation
# nixos-anywhere --extra-files "$temp" --flake '.#your-host' root@yourip
#SHELL=/bin/sh nix run github:nix-community/nixos-anywhere --\
#--flake .#$target_hostname \
#root@$target_destination
#SHELL=/bin/sh nix run github:nix-community/nixos-anywhere --\
SHELL=/bin/sh nix run github:EmergentMind/nixos-anywhere#rsync-scp -- --extra-files "$temp" \
	--flake .#$target_hostname root@$target_destination

#wait

#echo "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
#ssh-keyscan $target_destination >>~/.ssh/known_hosts

## connect to the new install generate hardware config based on the work declared by disko
#while timeout 10 ssh root@$target_destination -i ~/.ssh/id_meek "nixos-generate-config" -- exit 0; do sleep 1; done

## copy the target hardware config to nix-config on the source
#scp -i ~/.ssh/id_meek root@$target_destination:/etc/nixos/hardware-configuration.nix ../hosts/$target_hostname/hardware-configuration.nix

#git commit -am "feat: add hardware config for $target_hostname"
#git push

#ssh root@$target_destination -i ~/.ssh/id_meek
#git clone https://github.com/EmergentMind/nix-config.git
#cd nix-config
#nixos-rebuild switch --flake .#$target_hostname
