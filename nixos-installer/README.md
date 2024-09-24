#FIXME this needs cleanup and correction to a few things

# Nix Environment Setup for an existing host

This flake prepares a Nix environment for setting my systems up on a new machine, which allows easier testing and early
configuration tweaks.

- [Nix Environment Setup for an existing host](#nix-environment-setup-for-an-existing-host)
  - [Why an extra flake?](#why-an-extra-flake)
  - [Brand new host](#brand-new-host)
  - [Steps to Deploying this flake](#steps-to-deploying-this-flake)
    - [0. VM setup (optional)](#0-vm-setup-optional)
    - [1a. Automated With nixos-anywhere](#1a-automated-with-nixos-anywhere)
    - [1b. Manual Setup (Host/VM)](#1b-manual-setup-hostvm)
      - [1b.0 Encrypting with LUKS(everything except ESP)](#1b0-encrypting-with-lukseverything-except-esp)
      - [1b.1 Generating the NixOS Configuration and Installing NixOS](#1b1-generating-the-nixos-configuration-and-installing-nixos)
    - [1c. Manual Setup (Cloud)](#1c-manual-setup-cloud)
  - [2. Deploying the main flake's NixOS configuration](#2-deploying-the-main-flakes-nixos-configuration)
  - [3. Change LUKS2's passphrase and enroll yubikeys](#3-change-luks2s-passphrase-and-enroll-yubikeys)
  - [4. Everything else](#4-everything-else)

## Why an extra flake?

The configuration of the main flake, [/flake.nix](/flake.nix), is heavy, and it takes time to debug
& deploy. This simplified flake is tiny and can be deployed very quickly, it helps to:

1. Adjust & verify my `hardware-configuration.nix` modification quickly before deploying the main
   flake.
2. Test some new filesystem related features on a NixOS virtual machine, such as impermanence,
   Secure Boot, TPM2, Encryption, etc.

## Brand new host

- Add `hosts/<hostname>/` files
- Find disk name from livecd with `lsblk`
- Find RAM amount form livcde with `free -m`
- Add `nixos-installer/flake.nix` entry, and pass disk name and swap
- Add an age key to age_keys entry in nix-secrets (FIXME: This can be automated)
- If you'll be using backup, add a borg passphrase to nix-secrets

## Steps to Deploying this flake

- Run `just iso` to generate the iso file and use the `result/iso/*.iso` file to boot into it on the target machine/vm
- Run `just iso-install <disk>` to generate the iso file automatically copy it to a USB drive

### 0. VM setup (optional)

This is only relevant if you are not using a physical system.

- If you are using swap, remember a lot of space will be used for swap from your main disk (maybe 16GB) so setup a 40GB
  if you want a 20GB disk, or pass `withSwap = false;` to the disko module in `nixos-installer/flake.nix`
- Setup UEFI
- Add the DVD-rom pointing to the iso
- Add the yubikey device
- Record the ip address after initial boot

### 1a. Automated With nixos-anywhere

This will automatically setup the disks and install the nixos-installer flake using nixos-anywhere.

If you plan to use sops home-manager module on the target, you should first generate an age key for the target (if one
doesn't already exist) and put the contents of the key.text file into the nix-secrets secrets.yaml file, under
`age_keys`. Generate the age key using the following command:

```bash
nix-shell -p age.out --run 'age-keygen'
```

Be sure to specify `--impermanence` if necessary. Use `--debug` if something goes wrong...

Change the boot order so DVD-ROM is second and the installation disk is first. This is because nixos-anywhere will reboot this system and expect it to boot into the new system.

This is an example of running it from `nix-config` base folder installing on a VM (`okra`):

```bash
scripts/bootstrap-nixos.sh -n=okra -d=192.168.122.29 -k=~/.ssh/id_dade -u=root --impermanence
```

This will give you of few yes/no questions, but if everything works you should end up with a fully functional system
running the main flake (even though it first transitions through nixos-installer flake first).

You should test the passwords work as expected.





### 1b. Manual Setup (Host/VM)

If you end up needing to manually test steps, this explains the various things you need todo or that you may run into.

#### 1b.0 Encrypting with LUKS(everything except ESP)

ssh into the target system using your public key if using the custom iso.

Check the current disk layout:

```bash
❯ lsblk
NAME  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0   7:0    0  3.2G  1 loop /nix/.ro-store
sr0    11:0    1  3.2G  0 rom  /iso
vda   253:0    0   20G  0 disk
```

Record the disk identifier `vda`, as we will use it later.

Copy the repo from your host to the target:

```bash
just sync <user> <host>
```

For example, syncing to an ISO vm:

```bash
just sync nixos 192.168.129.29
```

Run disko:

```bash
cd nix-config/nixos-installer
just disko "/dev/vda" "passphrase"
```

Now, the disk status should be:

```bash
lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
loop0           7:0    0  3.2G  1 loop  /nix/.ro-store
sr0            11:0    1  3.2G  0 rom   /iso
vda           253:0    0   20G  0 disk
├─vda1        253:1    0  512M  0 part  /mnt/boot
└─vda2        253:2    0 19.5G  0 part
  └─cryptroot 254:0    0 19.5G  0 crypt /mnt/persist
                                        /mnt/nix
                                        /mnt/.swapvol
                                        /mnt
```

You can also confirm the naming of the volumes by running:

```bash
sudo btrfs subvolume list /mnt
ID 256 gen 7 top level 5 path @nix
ID 257 gen 9 top level 5 path @persist
ID 258 gen 18 top level 5 path @root
ID 259 gen 17 top level 5 path @swap
```

Turn swap on:

```bash
sudo swapon /mnt/.swapvol/swapfile
```

Check the status

```bash
$ sudo swapon -s /mnt/.swapvol/swapfile
Filename                                Type            Size            Used            Priority
/mnt/.swapvol/swapfile                  file            16777212        0               -2
```

#### 1b.1 Generating the NixOS Configuration and Installing NixOS

Then, generate the NixOS configuration:

```bash
# nixos configurations
sudo nixos-generate-config --root /mnt
```

From your installer host:

```
# we need to update our filesystem configs in old hardware-configuration.nix according to the generated one.
scp user@host:/mnt/etc/nixos/hardware-configuration.nix /hosts/<hostname>/hardware-configuration-new.nix
just sync <user> <host>
```

If you haven't already got a copy of this locally, you may want to scp it on to your host.

Then, install NixOS:

```bash
cd ~/nix-config/hosts/<host>/nixos-installer

# run this command if you're retrying to run nixos-install
rm -rf /mnt/etc

# install nixos
# NOTE: the root password you set here will be discarded when reboot
sudo nixos-install --root /mnt --flake .#okra --no-root-password --show-trace --verbose

# enter into the installed system, check password & users
# `su aa` => `sudo -i` => enter aa's password => successfully login
# if login failed, check the password you set and try again

# NOTE: DO NOT skip this step!!!
# copy the essential files into /persistent
# otherwise the / will be cleared and data will lost
mkdir /mnt/persist/etc

nixos-enter
mv /etc/machine-id /persist/etc/
mv /etc/ssh /persist/etc/
```

After finishing up, exit the nixos env.

```
# delete the generated configuration after editing
rm -f /mnt/etc/nixos
rm ~/nix-config/hosts/<host>/hardware-configuration-new.nix

# copy our configuration to the installed file system
cp -r ../nix-config /mnt/etc/nixos

# sync the disk, unmount the partitions, and close the encrypted device
sync
swapoff /mnt/.swapvol/swapfile
umount -R /mnt
cryptsetup close /dev/mapper/encrypted-nixos
reboot
```

And then reboot.

### 1c. Manual Setup (Cloud)

## 2. Deploying the main flake's NixOS configuration

For all systems we will use yubikey. For remote hosts, we will use yubikey-agent and for local we will end up plugging in the yubikey.

After all these steps, we can finally deploy the main flake's NixOS configuration by:

```bash
cd ~/nix-config
just rebuild
```

Finally, to enable secure boot, follow the instructions in
[lanzaboote - Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
and
[nix-config/ai/secure-boot.nix](https://github.com/ryan4yin/nix-config/blob/main/hosts/idols_ai/secureboot.nix)

## 3. Change LUKS2's passphrase and enroll yubikeys

```bash
# when entering /path/to/dev/ you must specify the partition (e.g. /dev/nvmeon1p2)
# test the old passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

# change the passphrase
sudo cryptsetup luksChangeKey /path/to/dev/

# test the new passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/
```

Enable yubikey support:

NOTE: This requires LUKS2 (use cryptsetup luksDump /path/to/dev/ to check)

```bash
sudo systemd-cryptenroll --fido2-device=auto /path/to/dev/
```

You will need to do it for each yubikey you want to use.

### Unlocking secondary drives after boot using crypttab and a keyfile
From - https://wiki.nixos.org/wiki/Full_Disk_Encryption#Unlocking_secondary_drives :

1. Create a keyfile for your secondary drive(s), store it safely and add it as a LUKS key:

```bash
# dd bs=512 count=4 if=/dev/random of=/luks-secondary-unlock.key iflag=fullblock
# chmod 400 /luks-secondary-unlock.key
```

You can specify your own name for `luks-secondary-unlock.key`
2. For each secondary device, run the following command and specify the respective device:

```bash
# cryptsetup luksAddKey /path/to/dev /luks-secondary-unlock.key
```

3. Create /etc/crypttab in configuration.nix using the following option (replacing UUID-OF-SDB with the actual UUID of /dev/sdb):

To list the UUIDs of the devices use: `sudo lsblk -o +name,mountpoint,uuid`
You need the UUID of the partition that the volume exists on, not the uuid of the volume itself

```nix
{
   environment.etc.crypttab.text = ''
    volumename UUID=UUID-OF-SDB /mykeyfile.key
  ''
}
```
exmaple:
```nix
{
   environment.etc.crypttab.text = ''
    cryptextra UUID=569e2951-1957-4387-8b51-f445741b02b6 /luks-secondary-unlock.key
  ''
}
```

With this approach, the secondary drive is unlocked just before the boot process completes, without the need to enter its password.
The secondary drive will be unlocked and made available under /dev/mapper/cryptstorage for mounting.

## 4. Everything else

Here you should have a fully working system, but some stuff you still need to do:

- login to proton
- Add new u2f_keys to nix-secrets if a totally new host
- Recover any backup files needed
  - .mozilla
  - syncthing
- Log into firefox
- Re-link signal
- Manually set syncthing username/password
- login to spotify
