# Install Notes

[README](../README.md) > Install Notes

## Building nix-config on a NixOS installation

This is a personalized configuration that has several technical requirements to build successfully. This nix-config will serve you best as a reference, learning resource, and template for crafting your own configuration. I am continuing to provide resources throughout the repository and my website to help but you must also experiment and learn as you go to be successful to create a NixOS environment that will meet your needs.

Assuming you have an adequately configured nix-secrets repository, linked to nix-config in the flake inputs _and_ that you have configured modules in nix-config to suit your hosts and home requirements, you can build the config using a convenient script as described in the next section.

## Automated remote installation

NixOS and this nix-config can be installed remotely from a source machine running nix to a target machine by running `./scripts/bootstrap-nixos.sh -n [hostname] -d [destination]`

The steps required for remote installation are detailed in [`nix-config/nixos-installer/README.md`](../nixos-installer/README.md).

Additionally, an in depth look the process is covered in the article and video [Remotely Installing NixOS and nix-config with Secrets]( https://unmovedcentre.com/posts/remote-install-nixos-config/) available on my website.

## Historical Installation Log

The following log of install steps have been retained for historical reference. While they may provide some insight into troubleshooting manual installation procedures they will not be updated as nix-config evolves.

### Remote installation using nixos-anywhere and a lightweight ./nixos-installer flake - Feb 27, 2024

This process involves remote, unattended installation of nixos on a target machine. As usual the steps here will refined during testing and automated, where applicable. A lightweight flake is used so that I can gradually test out new tools (e.g. nixos-anywhere, disko, declarative-disk encryption, impermanence, etc) overtime without compromising anything in the full nix-config.

The endgoal is to remotely deploy the full nix-config to new hosts with as little manual attention as possible.

I attempted to remotely install the full nix-config from the get go but of course, home-manager needs to be run after the install is complete and the nix-config source isn't loaded to the target so doing a home-manager switch isn't possible.
The solution then, is to perform the lightweight install first to establish secrets access keys, an ssh key that doesn't require passphrase, and install nixos, then remote into the host, clone the full repo and build from there. The passphrase-free key will then get wiped out.

#### Requirements:

- target machine, reachable by ssh, that will boot into a custom generated installer image
    - IMPORTANT: as of Mar 28, 2024 you must still use NixOS version 23.05. NixOS-anywhere relies on rsync which is not included
        in the 23.11 iso. There is an open issue to address this and while it could be worked around in the remote_install.sh script, the effort isn't worth the gain at this time.
    - knowledge of the drives is required for declarative partitioning and formatting via disko
- source machine, with flakes enabled that will remotely install nixos on the target.
- must have working access to the nix-secrets repo and able to modify the secrets

1. ~~Download nixos-minimal installation iso.~~
    Generate the custom installer
    example:
    `nix build ../nixos-installer/#vboxImage`

2. If installing on virtualbox, the following settings have been successful in the past:
   1. 8GB hdd or higher
   2. 8GB memory
   3. Settings / System / Motherboard - Enable EFI
   4. Settings / System / Processor - Enable PAE/NX
   5. Settings / System / Processor - Enable VT-x/AMD-V
   6. Settings / Display / Screen - Video memory 128MB
   7. Settings / Display / Screen - Select VMSVGA
   8. Settings / Display / Screen - Enable 3D Acceleration
   9. Settings / Network / Adapter 1 - Attached to: Bridge Adapter.
      Note the mac address under Advanced and add a static dhcp entry on guard.
   10. Load the iso as the boot media
3. Boot the target machine to the install environment.
4. On the target machine, set a temporary password for the root user, this will only be used during this installation process.
   ```bash
   $ sudo su
   # passwd
   New password:
   Retype new password:
   passwd: password updated successfully
   ```
5. If needed, note the ip of the target machine. `$ ip a`
7. This step should be optional. If we're installing the config right away, the basic root password we set up for install will get wiped out during build.

From the source machine, copy the ssh pub key you will use for installation and deployment on the target machine. If an unattended install is required, this ssh key pair should not require presence or passphrase. Depending on how the host is configured during install and/or rebuild however, this key could be intentionally wiped out in favor of an "everyday" key that requires presence of some sort.
   `ssh-copy-id -i path/to/key.pub root@<target ip>`
8. From the source machine, set up host keys and secrets access for the target:

   1. In the nix-secrets repo, generate a host ssh host key, and leave the passphrase empty. Replace `guppy` in the example below with whatever you intend to name the target machine via the config.

      For example:

      ```bash
      $ cd /path/to/nix-secrets
      $ ssh-keygen -t ed25519 -f ssh_host_ed25519_key -C root@guppy
      Generating public/private ed25519 key pair.
      Enter passphrase (empty for no passphrase):
      Enter same passphrase again:
      Your identification has been saved in ssh_host_ed25519_key
      Your public key has been saved in ssh_host_ed25519_key.pub
      The key fingerprint is:
      SHA256:0gwWR0Rnlps79k5XACX45EkesEBKH8JP3FkZ/NqcgUA ta@guppy
      The key's randomart image is:
      +--[ED25519 256]--+
      |     .+*OoEB=+.  |
      |     ..*o**.*o   |
      |      +o. .X =.  |
      |     . +. o * o. |
      |      . S  . + o.|
      |       .  + . +. |
      |         . o. .  |
      |           ...   |
      |           ..    |
      +----[SHA256]-----+
      ```

   2. Generate an age key for the target machine, based on the ssh hostkey you just created.
      ```bash
      $ nix-shell -p ssh-to-age --run 'cat ssh_host_ed25519_key.pub | ssh-to-age'
      age1jzrpvffcwjtv4e77v24ye44z2yk3nk3hkyjk60tfluuaxszdtf7s0u3xeh
      ```
   3. Add the age key as a host entry in the `.sops.yaml` file.

      ```yaml
      nix-secrets/.sops.yaml

      ------------------------------

      # pub keys
      keys:
      # ...
      - &hosts:
          - &guppy age1jzrpvffcwjtv4e77v24ye44z2yk3nk3hkyjk60tfluuaxszdtf7s0u3xeh

      creation_rules:
      - path_regex: secrets.yaml$
          key_groups:
          - age:
          # ...
          - *guppy

      ```

   4. Update the keys for the sops file
      ```bash
      $ sops --config path/to/nix-secrets/.sops.yaml updatekeys path/to/nix-secrets/secrets.yaml
      2024/02/09 12:11:05 Syncing keys for file /home/ta/src/nix-secrets/secrets.yaml
      The following changes will be made to the file's groups:
      Group 1
          age00000000000000000000000000000000000000000000000000
          age00000000000000000000000000000000000000000000000000
      +++ age1jzrpvffcwjtv4e77v24ye44z2yk3nk3hkyjk60tfluuaxszdtf7s0u3xeh
      Is this okay? (y/n):y
      2024/02/09 12:16:54 File /home/ta/src/nix-secrets/secrets.yaml synced with new keys
      ```
   5. Commit and push the changes to nix-secrets so they will be retrieved when the flake is built on the new host.
   6. Overwrite the auto generated host keys on the target machine with the private and public ssh host keys created in step 7.1 We can authenticate using the private key that matches the public key we added to the target machine's authorized keys in step 6.
      ```bash
      scp -i path/to/private/sshkey ssh_host_ed25519_key* root@0.0.0.0:/etc/ssh/
      ```
   7. Back up the keys and age key to a secure database if required.
   8. Delete the keys from the source machine
      `rm ssh_host_ed25519_key*`
   9. From the nix-config repo on the source machine, be sure to run `nix flake lock --update-input nix-secrets` to ensure the latest revisions of nix-secrets is used next time a rebuild occurs.
   10. Edit the source machine's `~/.ssh/known_hosts` file to remove the entries for the target machine's ip. We need to do this because new host keys will cause a mismatch the next time we remote into the target.

9. If you will be installing the lightweight test config, navigate to nixos-installer directory. Ortherwise, stay at the root fo the nix-config repo.
10. Run a remote install on the target. We prepend the SHELL variable to avoid shell mismatches that may be injected from the source machine. We'll also tell ssh to use the private key that matches the pub key from step 6.

   ```bash
   $ SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --flake <path to configuration>#<configuration name> root@<ip address> -i <local path to ssh key>`


   SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- --flake .#guppy root@10.13.37.100 -i ~/.ssh/id_meek
   ### Uploading install SSH keys ###
   /run/current-system/sw/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/tmp/tmp.jn2BRmy99e/nixos-anywhere.pub"
   Warning: Permanently added '10.13.37.100' (ED25519) to the list of known hosts.

   Number of key(s) added: 1

   Now try logging into the machine, with:   "ssh -o 'ConnectTimeout=10' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -o 'IdentityFile=/home/ta/.ssh/id_meek' 'root@10.13.37.100'"
   and check to make sure that only the key(s) you wanted were added.

   ### Gathering machine facts ###
   Pseudo-terminal will not be allocated because stdin is not a terminal.
   Warning: Permanently added '10.13.37.100' (ED25519) to the list of known hosts.
   Warning: Permanently added '10.13.37.100' (ED25519) to the list of known hosts.
   copying path '/nix/store/nxgy0s46bw9z3ysqv48nfszbrjxqy2dn-dns-root-data-2023-11-27' from 'https://cache.nixos.org'...

   # ...

   copying path '/nix/store/8qalcd1aj39whvpampmnarhybm7yz3ac-util-linux-2.39.3-bin' from 'https://cache.nixos.org'...
   ### Formatting hard drive with disko ###
   Warning: Permanently added '10.13.37.100' (ED25519) to the list of known hosts.
   umount: /mnt: not mounted
   ++ realpath /dev/sda
   + disk=/dev/sda
   + lsblk -a -f
   NAME   FSTYPE   FSVER            LABEL                      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
   loop0  squashfs 4.0                                                                                    0   100% /nix/.ro-store
   loop1
   loop2
   loop3
   loop4
   loop5
   loop6
   loop7
   sda
   ├─sda1 vfat     FAT16                                       DC53-F142
   └─sda2 btrfs                                                dc1ac286-2f8d-4bab-aab2-ed611767c043
   sr0    iso9660  Joliet Extension nixos-minimal-23.11-x86_64 1980-01-01-00-00-00-00                     0   100% /iso
   + lsblk --output-all --json
   + bash -x
   ++ dirname /nix/store/23hwv0dkl3bzx0fszw7zk154aapb1gdv-disk-deactivate/disk-deactivate
   + jq -r --arg disk_to_clear /dev/sda -f /nix/store/23hwv0dkl3bzx0fszw7zk154aapb1gdv-disk-deactivate/disk-deactivate.jq
   + set -fu
   + wipefs --all -f /dev/sda1
   /dev/sda1: 8 bytes were erased at offset 0x00000036 (vfat): 46 41 54 31 36 20 20 20
   /dev/sda1: 1 byte was erased at offset 0x00000000 (vfat): eb
   /dev/sda1: 2 bytes were erased at offset 0x000001fe (vfat): 55 aa
   + wipefs --all -f /dev/sda2
   /dev/sda2: 8 bytes were erased at offset 0x00010040 (btrfs): 5f 42 48 52 66 53 5f 4d
   ++ zdb -l /dev/sda
   ++ sed -nr 's/ +name: '\''(.*)'\''/\1/p'
   + zpool=
   + [[ -n '' ]]
   + unset zpool
   ++ lsblk /dev/sda -l -p -o type,name
   ++ awk 'match($1,"raid.*") {print $2}'
   + md_dev=
   + [[ -n '' ]]
   + wipefs --all -f /dev/sda
   /dev/sda: 8 bytes were erased at offset 0x00000200 (gpt): 45 46 49 20 50 41 52 54
   /dev/sda: 8 bytes were erased at offset 0x63ffffe00 (gpt): 45 46 49 20 50 41 52 54
   /dev/sda: 2 bytes were erased at offset 0x000001fe (PMBR): 55 aa
   + dd if=/dev/zero of=/dev/sda bs=440 count=1
   1+0 records in
   1+0 records out
   440 bytes copied, 0.0034589 s, 127 kB/s
   + lsblk -a -f
   NAME  FSTYPE   FSVER            LABEL                      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
   loop0 squashfs 4.0                                                                                    0   100% /nix/.ro-store
   loop1
   loop2
   loop3
   loop4
   loop5
   loop6
   loop7
   sda
   sr0   iso9660  Joliet Extension nixos-minimal-23.11-x86_64 1980-01-01-00-00-00-00                     0   100% /iso
   ++ mktemp -d
   + disko_devices_dir=/tmp/tmp.6A18VsQCSA
   + trap 'rm -rf "$disko_devices_dir"' EXIT
   + mkdir -p /tmp/tmp.6A18VsQCSA
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptP artitionFirst=1
   + type=gpt
   + sgdisk --align-end --new=1:1M:512M --change-name=1:disk-sda-ESP --typecode=1:EF00 /dev/sda
   Creating new GPT entries in memory.
   The operation has completed successfully.
   + partprobe /dev/sda
   + udevadm trigger --subsystem-match=block
   + udevadm settle
   + device=/dev/disk/by-partlabel/disk-sda-ESP
   + extraArgs=()
   + declare -a extraArgs
   + format=vfat
   + mountOptions=('defaults')
   + declare -a mountOptions
   + mountpoint=/boot
   + type=filesystem
   + mkfs.vfat /dev/disk/by-partlabel/disk-sda-ESP
   mkfs.fat 4.2 (2021-01-31)
   + sgdisk --align-end --new=2:0:-0 --change-name=2:disk-sda-root --typecode=2:8300 /dev/sda
   The operation has completed successfully.
   + partprobe /dev/sda
   + udevadm trigspiritualslvtVerified
   + type=btrfs
   + mkfs.btrfs /dev/disk/by-partlabel/disk-sda-root -f
   btrfs-progs v6.7.1
   See https://btrfs.readthedocs.io for more information.

   NOTE: several default settings have changed in version 5.15, please make sure
       this does not affect your deployments:
       - DUP for metadata (-m dup)
       - enabled no-holes (-O no-holes)
       - enabled free-space-tree (-R free-space-tree)

   Label:              (null)
   UUID:               660bfc51-f581-43ff-addc-f0f22e24ca86
   Node size:          16384
   Sector size:        4096	(CPU page size: 4096)
   Filesystem size:    24.50GiB
   Block group profiles:
   Data:             single            8.00MiB
   Metadata:         DUP             256.00MiB
   System:           DUP               8.00MiB
   SSD detected:       no
   Zoned device:       no
   Features:           extref, skinny-metadata, no-holes, free-space-tree
   Checksum:           crc32c
   Number of devices:  1
   Devices:
   ID        SIZE  PATH
       1    24.50GiB  /dev/disk/by-partlabel/disk-sda-root

   ++ mktemp -d
   + MNTPOINT=/tmp/tmp.9otThTuzON
   + mount /dev/disk/by-partlabel/disk-sda-root /tmp/tmp.9otThTuzON -o subvol=/
   + trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
   + SUBVOL_ABS_PATH=/tmp/tmp.9otThTuzON//nix
   ++ dirname /tmp/tmp.9otThTuzON//nix
   + mkdir -p /tmp/tmp.9otThTuzON
   + btrfs subvolume create /tmp/tmp.9otThTuzON//nix
   Create subvolume '/tmp/tmp.9otThTuzON/nix'
   ++ umount /tmp/tmp.9otThTuzON
   ++ rm -rf /tmp/tmp.9otThTuzON
   ++ mktemp -d
   + MNTPOINT=/tmp/tmp.tG7E4fbUcH
   + mount /dev/disk/by-partlabel/disk-sda-root /tmp/tmp.tG7E4fbUcH -o subvol=/
   + trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
   + SUBVOL_ABS_PATH=/tmp/tmp.tG7E4fbUcH//persist
   ++ dirname /tmp/tmp.tG7E4fbUcH//persist
   + mkdir -p /tmp/tmp.tG7E4fbUcH
   + btrfs subvolume create /tmp/tmp.tG7E4fbUcH//persist
   Create subvolume '/tmp/tmp.tG7E4fbUcH/persist'
   ++ umount /tmp/tmp.tG7E4fbUcH
   ++ rm -rf /tmp/tmp.tG7E4fbUcH
   ++ mktemp -d
   + MNTPOINT=/tmp/tmp.klJfrnx0TH
   + mount /dev/disk/by-partlabel/disk-sda-root /tmp/tmp.klJfrnx0TH -o subvol=/
   + trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
   + SUBVOL_ABS_PATH=/tmp/tmp.klJfrnx0TH//root
   ++ dirname /tmp/tmp.klJfrnx0TH//root
   + mkdir -p /tmp/tmp.klJfrnx0TH
   + btrfs subvolume create /tmp/tmp.klJfrnx0TH//root
   Create subvolume '/tmp/tmp.klJfrnx0TH/root'
   ++ umount /tmp/tmp.klJfrnx0TH
   ++ rm -rf /tmp/tmp.klJfrnx0TH
   ++ mktemp -d
   + MNTPOINT=/tmp/tmp.xAGjIYRi7p
   + mount /dev/disk/by-partlabel/disk-sda-root /tmp/tmp.xAGjIYRi7p -o subvol=/
   + trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
   + SUBVOL_ABS_PATH=/tmp/tmp.xAGjIYRi7p//swap
   ++ dirname /tmp/tmp.xAGjIYRi7p//swap
   + mkdir -p /tmp/tmp.xAGjIYRi7p
   + btrfs subvolume create /tmp/tmp.xAGjIYRi7p//swap
   Create subvolume '/tmp/tmp.xAGjIYRi7p/swap'
   + btrfs filesystem mkswapfile --size 8196M /tmp/tmp.xAGjIYRi7p//swap/swapfile
   create swapfile /tmp/tmp.xAGjIYRi7p//swap/swapfile size 8.00GiB (8594128896)
   ++ umount /tmp/tmp.xAGjIYRi7p
   ++ rm -rf /tmp/tmp.xAGjIYRi7p
   + set -efux
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptPartitionFirst=1
   + type=gpt
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptPartitionFirst=1
   + type=gpt
   + device=/dev/disk/by-partlabel/disk-sda-root
   + extraArgs=('-f')
   + declare -a extraArgs
   + mountOptions=('defaults')
   + declare -a mountOptions
   + mountpoint=
   + type=btrfs
   + findmnt /dev/disk/by-partlabel/disk-sda-root /mnt/
   + mount /dev/disk/by-partlabel/disk-sda-root /mnt/ -o defaults -o subvol=/root -o X-mount.mkdir
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptPartitionFirst=1
   + type=gpt
   + device=/dev/disk/by-partlabel/disk-sda-root
   + extraArgs=('-f')
   + declare -a extraArgs
   + mountOptions=('defaults')
   + declare -a mountOptions
   + mountpoint=
   + type=btrfs
   + findmnt /dev/disk/by-partlabel/disk-sda-root /mnt/.swapvol
   + mount /dev/disk/by-partlabel/disk-sda-root /mnt/.swapvol -o noatime -o subvol=/swap -o X-mount.mkdir
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptPartitionFirst=1
   + type=gpt
   + device=/dev/disk/by-partlabel/disk-sda-ESP
   + extraArgs=()
   + declare -a extraArgs
   + format=vfat
   + mountOptions=('defaults')
   + declare -a mountOptions
   + mountpoint=/boot
   + type=filesystem
   + findmnt /dev/disk/by-partlabel/disk-sda-ESP /mnt/boot
   + mount /dev/disk/by-partlabel/disk-sda-ESP /mnt/boot -t vfat -o defaults -o X-mount.mkdir
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptPartitionFirst=1
   + type=gpt
   + device=/dev/disk/by-partlabel/disk-sda-root
   + extraArgs=('-f')
   + declare -a extraArgs
   + mountOptions=('defaults')
   + declare -a mountOptions
   + mountpoint=
   + type=btrfs
   + findmnt /dev/disk/by-partlabel/disk-sda-root /mnt/nix
   + mount /dev/disk/by-partlabel/disk-sda-root /mnt/nix -o compress=zstd -o noatime -o subvol=/nix -o X-mount.mkdir
   + device=/dev/sda
   + imageSize=2G
   + name=sda
   + type=disk
   + device=/dev/sda
   + efiGptPartitionFirst=1
   + type=gpt
   + device=/dev/disk/by-partlabel/disk-sda-root
   + extraArgs=('-f')
   + declare -a extraArgs
   + mountOptions=('defaults')
   + declare -a mountOptions
   + mountpoint=
   + type=btrfs
   + findmnt /dev/disk/by-partlabel/disk-sda-root /mnt/persist
   + mount /dev/disk/by-partlabel/disk-sda-root /mnt/persist -o compress=zstd -o subvol=/persist -o X-mount.mkdir
   + rm -rf /tmp/tmp.6A18VsQCSA
   Connection to 10.13.37.100 closed.
   ### Uploading the system closure ###
   Warning: Permanently added '10.13.37.100' (ED25519) to the list of known hosts.
   copying path '/nix/store/n5gg6g0bninn45dq46ksw68ij6m407lj-alsa-firmware-1.2.4-xz' from 'https://cache.nixos.org'...
   # ...
   copying path '/nix/store/38l9qlglbavgascs0yzjpwd2h4rk4r74-etc-modprobe.d-firmware.conf' from 'https://cache.nixos.org'...
   ### Installing NixOS ###
   Pseudo-terminal will not be allocated because stdin is not a terminal.
   Warning: Permanently added '10.13.37.100hmmm thinking that tho
   Copied "/nix/store/s5dx34869kl4fd5p913j5mis32c7f98k-systemd-255.2/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/EFI/systemd/systemd-bootx64.efi".
   Copied "/nix/store/s5dx34869kl4fd5p913j5mis32c7f98k-systemd-255.2/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/EFI/BOOT/BOOTX64.EFI".
   ! Mount point '/boot' which backs the random seed file is world accessible, which is a security hole! !
   ! Random seed file '/boot/loader/.#bootctlrandom-seeded02790bc930e4ca' is world accessible, which is a security hole! !
   Random seed file /boot/loader/random-seed successfully written (32 bytes).
   Created EFI boot entry "Linux Boot Manager".
   installation finished!
   umount: /mnt/.swapvol unmounted
   umount: /mnt/boot unmounted
   umount: /mnt/nix unmounted
   umount: /mnt/persist unmounted
   umount: /mnt unmounted
   ### Waiting for the machine to become reachable again ###
   ### Done! ###
   ```

11. Now we can remote into the host and prepare to  deploy the full nix-config
12. Connect to host
13. Generate the hardware config based on the work done by dikso
   `# nixos-generate-config`
14. ! this step should probably be done on the source with an scp so that the host doesn't need access to the source. Copy the contents of `/etc/nixos/hardware-configuration.nix` to the appropriate directory in the repo. E.g. `hosts/<hostname>/hardware-configuration.nix`
15. commit and push the config
16. connect back to host
17. clone repo
18. nixos-rebuild switch
19. homemanager switch


### Rebuild - January 22, 2024

This covers installation of NixOS on grief (lab box) as a VirtualBox VM after hosing access to my original secrets.yaml and locking myself out of the original grief lab.
The official manual has some "NixOS in a VirtualBox guest" specific instructions that were used here.
There is mention of a pre-built nixos virtualbox appliance available but I chose hardmode.
https://nixos.org/manual/nixos/stable/#sec-installing-virtualbox-guest

1.  Download nixos iso
2.  Install VirtualBox on ghost.
3.  Start a new VM with the following settings:
    1. 8GB hdd or higher (I chose 250GB for lab purposes)
    2. 8GB memory
    3. Settings / System / Motherboard - Enable EFI
    4. Settings / System / Processor - enable PAE/NX
    5. Settings / System / Processor - enable VT-x/AMD-V
    6. Settings / Display / Screen - video memory 128MB
    7. Settings / Display / Screen - select VMSVGA
    8. Settings / Display / Screen - Enable 3D Acceleration
    9. Settings / Network / Adapter 1 - Attached to: Bridge Adapter.
       Note the mac address under Advanced and add a static dhcp entry on guard.
4.  Load the iso as the boot media
5.  Follow the install steps on the live environment:
    - use a basic password until ssh is setup
    - no desktop
    - allow unfree
    - use swap w/hibernate for devices with <=8GB RAM
6.  Perform install and reboot.
7.  We need to add our keys to the vm but I couldn't get virtualbox guest additions running on the basic nixos install. Instead, I temporarily enabled basic ssh access to `/etc/nixos/configuration.nix`.

    ```bash
    $ nix-shell -p neovim
    $ sudo nvim /etc/nixos/configuration.nix

    # edit the file
    ```

    Edit the following:

    1. ensure that the bootloader entry is as follows. If it is grub, you may not have enabled EFI in the previous steps.

       ```nix
       boot.loader.systemd-boot.enable = true;
       boot.loader.efi.canTouchEfiVariables = true;
       '''
       ```

    2. hostname 'grief'
    3. under "environment.systempackages" uncomment or enable the following packages:
       - neovim
       - git
       - sops
       - age
       - ssh-to-age
    4. uncomment `services.openssh.enable = true`
    5. at the end of the file at the following entry:
       `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
    6. save and exit the file

8.  Save the file and then rebuild nixos.

    ```bash
    $ sudo nixos-rebuild switch
    building Nix...
    building the system configuration...
    # ...
    ```

9.  ssh to the vm from ghost `ssh ta@0.0.0.0`
10. Now we'll add some authorized_keys so that we can ssh without a password

    ```bash
    $ nix-shell -p neovim
    $ mkdir .ssh
    $ nvim .ssh/authorized_keys

    .ssh/authorized_keys
    ---------
    <public key data>
    <public key 2 data>

    ```

11. Save and exit the file and then open a new terminal on ghost. Connect to grief over ssh again and confirm that it asks for authorization against one of the authorized keys we just added.
    If not, diagnose the issue.

12. Now we will need to copy the keys required to clone our private repo(s). On ghost, navigate to the .ssh directory and secure copy the appropriate public and private key-pair(s) to grief.

    on ghost:

    ```bash
    $ cd ~/.ssh
    $ ls
    id_maya id_maya.pub ...
    $ scp id_manu* ta@0.0.0.0:.ssh/
    $ scp id_maya* ta@0.0.0.0:.ssh/
    ```

13. Next you need to temporarily configure ssh to use ours keys when connecting to gitlab.com
    This is temporary because we'll need to delete this file when we rebuild nixos using our flake. Otherwise home-manager will complain that the file is in its way. On grief:

        ```config
        ~/.ssh/config
        -----------------------
        Host gitlab.com
            IdentitiesOnly yes
            IdentityFile ~/.ssh/id_maya
            IdentityFile ~/.ssh/id_manu
        Host github.com
            IdentitiesOnly yes
            IdentityFile ~/.ssh/id_maya
            IdentityFile ~/.ssh/id_manu
        ```

14. Clone the `nix-config` repo.

    ```bash
    $ mkdir ~/src
    $ cd ~/src
    $ git clone git@gitlab.com:emergentmind/nix-config.git
    Cloning into 'nix-config'...
    The authenticity of host 'gitlab.com' can't be established.
    ED25519 key fingerprint is SHA256:000000000000000000000000000000000000000000
    This key is not known by any other names.
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added 'gitlab.com' (ED25519) to the list of known hosts.
    Confirm user presence for key ECDSA-SK SHA256:000000000000000000000000000000000000000000
    sign_and_send_pubkey: signing failed for ECDSA-SK "/home/ta/.ssh/id_maya": device not found
    Enter passphrase for key '/home/ta/.ssh/id_manu':
    remote: Enumerating objects: 1238, done.
    remote: Counting objects: 100% (111/111), done.
    remote: Compressing objects: 100% (19/19), done.
    remote: Total 1238 (delta 97), reused 92 (delta 92), pack-reused 1127
    Receiving objects: 100% (1238/1238), 252.02 KiB | 1.37 MiB/s, done.
    Resolving deltas: 100% (502/502), done.
    ```

15. Clone the `nix-secrets` repo. Normally we wouldn't do this because it is a flake input for nix-config, however in this case we need to recreate `secrets.yaml` in both locations until we refactor.

    ```bash
    $ git clone git@gitlab.com:emergentmind/nix-secrets.git
    Cloning into 'nix-secrets'...
    Confirm user presence for key ECDSA-SK SHA256:000000000000000000000000000000000000000000
    sign_and_send_pubkey: signing failed for ECDSA-SK "/home/ta/.ssh/id_maya": device not found
    Enter passphrase for key '/home/ta/.ssh/id_manu':
    remote: Enumerating objects: 16, done.
    remote: Counting objects: 100% (16/16), done.
    remote: Compressing objects: 100% (15/15), done.
    remote: Total 16 (delta 4), reused 0 (delta 0), pack-reused 0
    Receiving objects: 100% (16/16), 9.68 KiB | 9.68 MiB/s, done.
    Resolving deltas: 100% (4/4), done.
    ```

16. We'll need to use the hardware-configuration.nix that was generated for this vm during the nixos-rebuild we did in earlier. Copy it to the hosts directory of the nix-config repo

    ```bash
    $ cd nix-config
    $ cp /etc/nixos/hardware-configuration.nix hosts/nixos/grief/
    ```

17. Add git user info so that the changes can be successfully committed and pushed

    ```bash
    $ git config --global user.name "emergentmind"
    $ git config --global user.email "2889621-emergentmind@users.noreply.gitlab.com"
    ```

18. Commit the new hardware config

    ```bash
    $ git commit -a -m "add vm hardware config for grief"
    [dev a34ef60] add vm hardware config for grief
    1 file changed, 6 insertions(+), 14 deletions(-)
    ```

19. Push the changes with `git push`
20. Rename the .ssh/config so it doesn't conflict with our flake config
    `mv ~/.ssh/config ~/.ssh/config.bkp`
21. Copy our ta/dev user age key to grief.
    On ghost:

    ```bash
    $ scp ~/.config/sops/age/keys.txt ta@0.0.0.0:.config/sops/age/
    (ta@0.0.0.0) Password:
    keys.txt
    ```

22. Next we'll generate age keys for grief based on its ssh host keys (these would have been auto-created when enabling ssh earlier on)

    ```bash
    $ nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    this path will be fetched (0.94 MiB download, 2.70 MiB unpacked):
    /nix/store/j1nbcdrr1xqc6swycq0c361sxrpm54fy-ssh-to-age-1.1.3
    copying path '/nix/store/j1nbcdrr1xqc6swycq0c361sxrpm54fy-ssh-to-age-1.1.3' from 'https://cache.nixos.org'...
    age10000000000000000000000000000000000000000000000000000
    ```

    Add the age key to .sops.yaml. Since we're in a recovery state, we'll do this on the .sops.yaml for both repos (nix-config and nix-secrets) since we'll eventually be reducing it down to one.

    ```bash
    $ nvim src/nix-config/.sops.yaml

    .sops.yaml

    ---------
    # pub keys
    keys:
    - &users:
        - &ta age10000000000000000000000000000000000000000000000000000 #primate age key
    - &hosts: # nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
        - &grief age0000000000000000000000000000000000000000000000000000

    creation_rules:
        #path should be relative to location of this file (.sops.yaml)
    - path_regex: hosts/common/secrets.yaml$
        key_groups:
        - age:
        - *ta
        - *grief

    ---------

    $ cp src/nix-config/.sops.yaml src/nix-secrets
    ```

23. Now we're ready to recreate `secrets.yaml` using sops
    Note: something was up with the EDITOR environment variable wanting xterm kitty so first I ran
    `export EDITOR=nvim` then i deleted the old, inaccessilbe copy of secrets.yaml from nix-config using `rm ~/src/nix-config/hosts/common/secrets.yaml`

    ```bash
    $ cd ~/src/nix-config
    $ sops hosts/common/secrets.yaml

    secrets.yaml
    -------
    keys:
        ssh:
            maya: <private key data>
            mara: <private key data>
            manu: <private key data>
        u2f: <key data>
    passwords:
        ta: <password>
        media: <password>
        msmtp: <password>
    ```

24. Copy the new `secrets.yaml` from `nix-config` to `nix-secrets`
25. Commit and push the changes to nix-config.

    ```bash
    $ cd ~/src/nix-config
    $ git commmit -a -m "updated sops files"
    [dev 157d414] updated sops files
    2 files changed, 24 insertions(+), 23 deletions(-)
    $ git push
    Enter passphrase for key '/home/ta/.ssh/id_manu':
    Enumerating objects: 11, done.
    Counting objects: 100% (11/11), done.
    Delta compression using up to 4 threads
    Compressing objects: 100% (6/6), done.
    Writing objects: 100% (6/6), 4.01 KiB | 4.01 MiB/s, done.
    Total 6 (delta 3), reused 0 (delta 0), pack-reused 0
    To gitlab.com:emergentmind/nix-config.git
    c0c9ef2..157d414  dev -> dev
    ```

26. Now we should be able to `sudo nixos-rebuild switch --flake .#grief`
    If all went well we can also switch to our home-manager config
    `home-manager switch --flake .#ta@grief`

27. On successful rebuild `rm ~/.ssh/config.bkp`

### First Install - November 29, 2023

Installing on Asus mini-pc. This will replicate functionality of Gusto, which is a simple theatre box with browser and vlc, and is currently running on a Raspberry Pi 4. The project will start a lightweight foundation for building out a multi-host, multi-hardware configuration and doftile repo.

#### Install a minimal image via flashed USB device

https://nixos.org/manual/nixos/stable/#sec-installation-booting

Follow graphical installation steps until first reboot.

1. set up basic password until ssh is set up
2. no desktop (define later in the flake)
3. select allow unfree
4. use swap w/hibernate for devices with <8GB RAM
5. perform install and reboot
6. once you're at the terminal (no desktop installed ;) )

   ```bash
   cd /etc/nixos
   sudoedit configuration.nix
   ```

7. edit the the following:
   1. hostname
   2. under "environment.systempackages" uncomment or enable the following packages:
      - vim
      - git
   3. uncomment `services. openssh.enable = true`
   4. at the end of the file at the following entry:
      `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
   5. save and exit the file
8. `sudo nixos-rebuild switch` to rebuild the system according to the configuration
9. now that the host system is configured for ssh switch over to your main box
10. add your public key as an authorized_key to the nix host `ssh-copy-id -i ~/.ssh/manual_ed25519.pub [user]@[ip-address]` enter the basic password defined during install
11. in order to push and pull from the nix-config git repo you'll need your private and public id_ed25519 files present on the new host. Copy them over using the following command. You may need to modify it according to the number of keys you have of that type.
    `scp .ssh/manual_ed* <user>@<ip>:.ssh/`
12. connect to the nix host `ssh <user>@<ip>` to the nix host using the passphrase for your pub key
13. `passwd <user>` to change the basic install password to something more secure
14. verify that the .ssh keys you copied over have the appropriate permissions

```bash
$ ls ~/.ssh
-rw------- 1 ta ta  444 Dec 1  2020 manual_ed25519
-rw-r--r-- 1 ta ta   95 Dec 1  2020 manual_ed25519.pub
```

15. Next you need to configure ssh to use the key when connecting to gitlab.com

```config
~/.ssh/config
-----------------------
 Host gitlab.com
     IdentitiesOnly yes
     IdentityFile ~/.ssh/manual_ed25519
```

16. Now we'll grab our nix-config flake from the repo
17. `mkdir -p src` to create the location for our flakes
18. `cd src`
19. clone the repo `git clone git@gitlab.com:emergentmind/nix-config.git`
20. We'll need to use the hardware-configuration.nix that was generated for this system during the nixos-rebuild we did in step 2. copy it to the hosts directory of the repo
21. `cd nix-config/`
22. `mkdir hosts/<hostname>`
23. `cp /etc/nixos/hardware-configuration.nix ./hosts/<hostname>` to copy the file to the correct location in the nix-config
24. we'll also need a basic host config that points to the hardware config:

    ```bash
    cat > "hosts/<hostname>/<hostname>.nix" << EOF
    {
        imports = [
            ./hardware-configuration.nix
        ];
        #----Host specific config ----
    }
    EOF
    ```

25. Now the host is ready and we can rebuild the system according to the flake
26. `sudo nixos-rebuild switch --flake .#<hostname>` to rebuild the configuration using the flake
27. Add git user info so that the changes can be successfully committed and pushed

    ```bash
    $ git config --global user.name "emergentmind"
    $ git config --global user.email "2889621-emergentmind@users.noreply.gitlab.com"

    ```

28. now we'll add the lock and and hosts hardware file to the repo

    ```bash
    $ git add .
    $ git commit -m "message"
    $ git push
    ```

    Once the rebuild completes it's time to start customizing the flake, step by step.

---

[Return to top](#install-notes)

[README](../README.md) > Install Notes
