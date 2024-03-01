#!/usr/bin/env bash
set -euo pipefail

target_hostname=""
target_destination=""
ssh_ssh_key=""
remote_remote_passwd="root"
# Create a temp directory for generated host keys
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Help function
help_and_exit()
{
  echo "Remotely installs NixOS on a target machine using this nix-config."
  echo "Usage: $0 -n=<target_hostname> -d=<target_destination> -k=<ssh_key> [options]"
  echo "Required:"
  echo "  -n=<target_hostname>          Specify target_hostname of the target host to deploy the NixOS config on."
  echo "  -d=<target_destination>   Specify ip or url to the target host."
  echo "  -k=<ssh_key>           Specify the full path to the public ssh_key you'll use for subsequent remote access ot the target host."
  echo "                     Example: -k=/home/ta/.ssh/my_ssh_key.pub"
  echo ""
  echo "options:"
  echo "  -p=<remote_passwd>        Specify a password for target machine root user."
  echo "                     Default='root'."
  echo "  -h | --help        Print this help."
  exit 0
}

# Handle options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n=*) target_hostname="${1#-n=}"
      ;;
    -d=*) target_destination="${1#-d=}"
      ;;
    -k=*) ssh_key="${1#-k=}"
      ;;
    -p=*) remote_passwd="${1#-p=}"
      ;;
    -h | --help) help_and_exit ;;
    *)
      echo "Invalid option detected."
      help_and_exit ;;
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

echo "Adding ssh ssh_key fingerprint at $target_destination to ~/.ssh/known_hosts"
ssh-keyscan $target_destination >> ~/.ssh/known_hosts

echo "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Generate host keys without a passphrase
ssh-keygen -t ed25519 -f $temp/etc/ssh/ssh_host_ed25519_key -C root@$target_hostname -N null

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

ls $temp/etc/ssh/

echo "Generating an age key based on ssh_host_ed25519_key."

age_key=$(nix-shell -p ssh-to-age --run "cat $temp/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age")

if grep -qv '^age1' <<< "$age_key"; then
  echo "The result from generated age ssh_key does not match the expected format."
  echo "Result: $age_key"
  echo "Expected format: age10000000000000000000000000000000000000000000000000000000000"
  exit 1;
else
  echo "$age_key"
fi

echo "Updating nix-secrets/.sops.yaml"

sops_str1="     - &$target_hostname $age_key"
sops_str2="          - *$target_hostname"

sed -i "/&hosts:/$sops_str1" .tmp.yaml 
sed -i "/age:/$sops_str2" .tmp.yaml 

exit 
# Install NixOS to the host system with our secrets
# nixos-anywhere --extra-files "$temp" --flake '.#your-host' root@yourip

# Execute installation
#SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake .#guppy root@10.13.37.100 -i ~/.ssh/id_meek