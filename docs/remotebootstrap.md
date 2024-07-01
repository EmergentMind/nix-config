# Remotely Bootstrapping NixOS and nix-config

NOTE: Introductions, Tools  and nix-config modifications sections have been moved to [unmovedcentre.com](https://unmovedentre.com)

## Automation script order of operations

With our config ready to go we can detail the order in which all of the steps of the installation process need to happen and how we automate them in our `/scripts/bootstrap-nixos.sh` script.

For reference, the entire automation script as of this writing is displayed here. Below it we'll walk through each of the steps it executes and why.

```bash
nix-config/scripts/bootstrap-nixos.sh
--------------------

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
		echo -e "\x1B[32m[!] $($2) \x1B[0m"
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
fi
else
	echo
	green "NixOS was succcefully installed!"
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
```

### Setting exit options

`set -eo pipefail` will ensure that if command in the script fails the `exit` built in utility will fire (via `-e` ) and that this will occur if any command in the pipeline fails (via `-o pipefail`).

### User variables

At the top of the script we have several variables and some default values. Most of the variables can be set using command line arguments when script is executed.

```bash
# User variables
target_hostname=""
target_destination=""
target_user="ta"
ssh_key=""
ssh_port="22"
persist_dir=""
```

The `target_*` variables will contain the name, IP or domain name, and primary user of the target machine. In my case I've set "ta" as the default for `target_user` since that will invariably my primary user name.
`ssh_key` is the variable that will contain a path to the ssh key we'll use for remotely accessing the target during the installation process.
`ssh_port` allows a custom port to be set, with a default being the typical ssh port 22.
`persist_dir` will only be populated if the `--impermanence` flag is used during script execution. More information on this is explained in the section on [handling command-line arguments](#handling-command-line-arguments).

### Temp dir and automatic clean up

The next section of the scripts includes the creation of a temporary directory, passed to the `temp` variable and a simple `cleanup` function that is called automatically by `trap`.

```bash
# Create a temp directory for generated host keys
temp=$(mktemp -d)

# Cleanup temporary directory on exit
function cleanup() {
	rm -rf "$temp"
}
trap cleanup exit
```

We'll be generating the host ssh key for our target on the source machine and then passing it to the target during installation. This is obviously important data, so we will store the key in a temporary directory created using `mktemp`. Our `cleanup` function will forcefully and recursively remove the temp directory for us. The builtin `trap` function will trigger automatically on any script exit signal - regardless of whether the script succeeded or if there was a failure of some sort (think back to [setting exit options](#setting-exit-options)) - and  run `cleanup` before actually exiting the script. This will ensure that all of the key data is removed from the source machine, regardless of the script execution outcome.

### Helper functions

The `red`, `green`, and `yellow` functions allow coloured output to the terminal to draw attention where needed.

The `yes_or_no` function will effectively pause script execution until we provide a response. The function defaults to 'y' so that we simply need to hit enter to continue.

The `sync` function is a simple wrapper for the `rsync` utility that passes in values according to the variables set during script execution.

The `help_and_exit` function prints usage and argument information to the cli for quick reference.

### Handling command-line arguments

You can see in the following `while` statement how we set the [user variables](#user-variables) we described above.

```bash
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
```

#### The impermanence flag and persist_dir variable

Of note here, is the `--impermanence` flag, which populates the `persist_dir` variable with the value "/persist". This flag should only be used when we enable impermanence which, as of this writing, is not yet the case. However, it's worth noting what this variable is used.

At a very high level, when using impermanence the system will be configured to wipe out any data on shutdown that isn't explicitly defined as _persistent_. Data that are persistent will be stored in a dedicated _persist_ sub-volume (as defined in our disko configuration FIXME: link to disko config section) that will be either accessible during normal operation or used to populate other areas of the system during boot. For example, a host level ssh key is normal stored in `/etc/ssh` but on an impermanence enabled system `/etc` gets deleted every time the system shuts down. So long-term, persistent data like the ssh key needs to be stored in location such as `/persist/etc/ssh` and is then copied to the fresh `/etc/ssh` during boot. In the `/persist/etc/ssh` example, "/persist" is the persistent directory and the "/etc/ssh" portion mimics the location of where the data will be copied to.

Therefore, by setting the `persist_dir` to a value of "/persist" we can ensure that when the script will write specific data to the persistent sub-volume of the target host _and_ that it will eventually be written to the correct system location.

When the script is run without using the `--impermanence` flag, `persist_dir` is just an empty string, so wherever we can use it dynamically in the script.

### ssh command wrappers






#### Preparation

On the source machine, we'll first want to edit our `~/.ssh/known_hosts` file to delete any entries that include the IP address of the target machine.

Next we'll need to generate an ssh host key for the target machine that will be installed using nixos-anywhere's `--extra-files` argument. To do this we'll first use `install` to create a directory structure to temporarily house the ssh host key. `install -d -m755 "

for where sshd will expect to find the host keys.

create a directory for sshd to pick up a specified host key
generate a host key to the directory
update permissions
fingerprint the target

cd nixos-installer
prep temp password for disko
    explain
syncing nix-config to target
    explain sync rather than clone is faster
generate hw-config
copy the hw-config to source
resync nix-config to target (places hw-config in correct location on both systems)

#### installation

For the initial installation of NixOS we'll be using nixos-anywhere (FIXME add link to tools section) and the root user provided by the custom ISO environment.

instantiate nixos-anywhere using minimal flake (since we are currently in nixos-installer dir)

#### post install

update ssh fingerprints
Persistance stuff (perhaps wait on this?)

### Generate Age Keys

### Adding ssh host fingerprints for gitlab and github

### Copying the nix-config

At this point of the process we'll switch from using the root user that was provided by the ISO to our primary user, that was created and configured during installation according to our minimal flake.
Also, when we copied the nix-config to the ISO image for use during installation, it was not retained when we rebooted and entered the installation. So first we'll need to copy the nix-config over to our primary user's home on the target and we'll also copy nix-secrets
    remind that sync rather than clone is faster

### Building nix-config

note about this being optional in the script and that we print the manual instructions as a helper.

### Pushing the target's hardware-configuration

### Change LUKS2's passphrase and enroll yubikeys

1. Change the temporary passphrase ("passphrase") set by `bootstraph-nixos.sh` to a permanent and secure passphrase. This will act as a manual fallback if you also complete step 2.

    ```bash
    # test the old passphrase
    sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

    # change the passphrase
    sudo cryptsetup luksChangeKey /path/to/dev/

    # test the new passphrase
    sudo cryptsetup --verbose open --test-passphrase /path/to/dev/
    ```

2. Enable yubikey support. NOTE: This requires LUKS version 2 aka LUKS. You can run `cryptsetup luksDump /path/to/dev/` to confirm version.

    ```bash
    sudo systemd-cryptenroll --fido2-device=auto /path/to/dev/
    ```

    TODO: info about doing this headless

3. Repeat step 2 for each yubikey you want to use.

## Impermanence Setup Notes from FidgetingBits 

FIXME: this impermanence section needs some edits. Also, publish this as a separate article authored by fbits about impermanence that the bootstrap article references. Add additional impermanence article references from roadmap refernces.keep the Change LUKS2's passphrase steps in the bootstrap instructions though.

I setup impermanence on a VM to start, but ran into a bunch of different problems before getting them all working.
Although there's a lot of good resources online about impermanence in general, nothing specifically addressed all of my
issues, so I had to resort to forum posts and just trawling other people's config, as well as documentation.

Basically my requirements are:

- Use impermanence
- Devices use `boot.initrd.systemd.enable = true`
- Disks setup by disko
- Use btrfs subvolumes
- Don't bother using a blank snapshot to avoid having to create it at startup
- Support having root snapshots for a period of time
- Should work on VMs and real systems

### systemd initrd

I have some systems with TPM and I want the option to be able to unlock luks using the TPM, which requires the use of
`boot.initrd.systemd.enable`, as described in 
https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167. I realized this was a problem when I
specified a script in `boot.initrd.postDeviceCommands` and didn't seem to be taking. The solution is to use a systemd
service that gets started early in the boot process.

In order for the systemd service to actually run at the right time you have to be careful about what `after` entries you
run after. The main one is you have to be sure that the luks device is actually available prior to running the roll back
otherwise it will fail. This requires you to know the disk label, so you can specify a `<disk>.device` entry.

In my case I use they luks device at `/dev/mapper/encrypted-nixos`. At first I kept noticing that it was trying todo the
rollback prior to the decryption, and it ended up being because the disk label I used was wrong. This is because I have
`-` in the name, so you need to use special encoding:

```nix
      after = [
        "dev-mapper-encrypted\\x2dnixos.device"
        # LUKS/TPM process
        "systemd-cryptsetup@${hostname}.service"
      ];
```

You can see that you have to hex escape the `-` because to create the otherwise `/`-based part of a device path when
specifying the `.device`, they already use `-` as the delimiter.

I made this realization after looking at Misterio77 repo: https://github.com/Misterio77/nix-config/blob/main/hosts/common/optional/ephemeral-btrfs.nix

### btrfs rollback script

A lot of people seem to first create a blank snapshot for their device, be it btrfs or ZFS. During the rollback process
they then restore the blank snapshot. The problem with this is that it adds an extra step that you need todo during
initial setup, whereas you can actually just recreate the sub volume at startup without having to restore a snapshot.

I should note however that this might prevent the easy ability to diff blank snapshots, versus the current snapshot,
which may be a reason to do it.

### rollback snapshot time limit

I'm currently hard coding a 30 day snapshot limit because I decided to keep the script separate from the nix source.
However there's a nice example of someone that's added options where they can use the nix config to specify the time
limit, which require implementing the shell script inside of nix expression itself.

Currently my hard coding looks like this:

```bash
if [[ -e /btrfs_tmp/@root ]]; then
	mkdir -p /btrfs_tmp/@old_roots
	timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%-d_%H:%M:%S")
	mv /btrfs_tmp/@root "/btrfs_tmp/@old_roots/$timestamp"
fi
```

But see https://github.com/hmajid2301/dotfiles/blob/main/modules/nixos/system/impermanence/default.nix for a nice way to
integrate the time limit option from the nix config, which is what I plan todo eventually.

### Stuck waiting 10 seconds for luks device

Originally well setting all of this up on a vm, in using disko, Even though it wasn't specifically a the impermanent
problem I still ran into an issue where I was stuck waiting for the luks device to come up:

https://discourse.nixos.org/t/stuck-waiting-10-seconds-for-luks-device/33423

This ended up being because I the kernel modules that seem to be specified by hard work configuration weren't applying
properly, and I also found that there was a kernel modules definition of `availableKernelModules` rather than
`kernelModules`. So I ended up hard coding the values directly into the configuration independent of the hardware
configuration part, which ensured that the `virtio` drivers needed to access they qemu disks were available at the time
of luks decrypt.

```nix
  boot.initrd = {
    systemd.enable = true;
    # FIXME: Not sure we need to be explicit with all, but testing virtio due to luks disk errors on qemu
    # This mostly mirrors what is generated on qemu from nixos-generate-config in hardware-configuration.nix
    # NOTE: May be important here for this to be kernelModules, not just availableKernelModules
    kernelModules = [
      "xhci_pci"
      "ohci_pci"
      "ehci_pci"
      "virtio_pci"
      "virtio_scsci"
      "ahci"
      "usbhid"
      "sr_mod"
      "virtio_blk"
    ];
  };
```

I'm not entirely sure which parts of the above fix were entirely necessary, but it works for now so I have an
experimented further.

### btrfs subvolume labeling

Because I like doing things in a way that apparently nobody else does, I chose to label all of my sub volumes using @,
in order to differentiate them from regular files/folders. This doesn't really create any huge problems but it's worth
noting that any scripts that you see other people using for both disko sub volume setup and also for snapshot deletion
will have to be adjusted to use that labeling.

This isn't a strict convention but it's fairly common and I like the reasoning, you can find a jump pad to a bunch of
discussions here: https://askubuntu.com/questions/987104/why-the-in-btrfs-subvolume-names

It should be noted that even though I like this style I might not be using it the exact same way is some other set ups
because I think some people use @ as an actual root?

## Putting it all together

### 1. Boot the target to a custom ISO

Build the custom ISO image as described in the section [The ISO image configuration module](FIXME) and boot your target bare-metal or virtual machine. Once the machine is booted into the ISO, we can proceed with remote installation from the source machine. Take note of the target machine's IP address. There are numerous ways of determining the machine's IP address or statically assigning it depending on how your network is set up but that is beyond the scope of this article.

### 2. Run the script

With the target host booted, we'll simply need to run the automation script from the root of our nix-config on the source machine. The basic command is `./scripts/bootstraph-nixos.sh -n <target_hostname> -d <target_destination> -k <ssh_key>`


 It's worth noting that, as is always the case, there is room for improvement here, as always.