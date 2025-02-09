# NixOS Installer for Nix-Config

This flake is separate from the main nix-config flake and prepares a Nix environment for bootstrapping a nix-config host on a new machine. Most of the process is automated with the [`nixos-bootstrap.sh`](../scripts/nixos-bootstraph.sh) script that is run on a "source" host to install NixOS on a "target" machine. There are a couple of small manual steps that are typical of any OS installation procedure, such defining information about the target host and adding host-specific secrets to the relevant sops secrets file. This document explains some of the reasoning behind the use of a separate flake and then provides installation steps. For a more indepth look at some of the concepts, reasoning, and automation process, see the blog post [Remotely Installing NixOS and nix-config with Secrets](https://unmovedcentre.com/posts/remote-install-nixos-config/) on my website. Note that the blog post was written during the first iteration of the bootstrap script and there have been significant enhancements to the code since that time. The general idea and flow still stand and may provide useful insight to understanding the script itself, for those who want to learn more about what it does.

- [Why an extra flake?](#why-an-extra-flake)
- [Assumptions](#assumptions)
- [Generating a custom NixOS ISO](#generating-a-custom-nixos-iso)
- [Requirements for Installing a New Host](#requirements-for-installing-a-new-host)
- [Requirements for installing an existing nix-config host on a new machine](requirements-for-installing-an-existing-nix-config-host-on-a-new-machine)
- [Installation Steps](#installation-steps)
- [Troubleshooting](#Troubleshooting)

## Why an extra flake?

The main flake, `nix-config/flake.nix`, takes longer to build, debug, and deploy because even the core modules are focused on a broad set of functional requirements. In contrast, this simplified flake is focused only on providing an environment with which to accomplish the following:

- Prepare the machine to successfully authenticate with our private nix-secrets repo _and_ decrypt the required secrets when the main flake is built.
- Adjust and verify the new host's `hardware-configuration.nix` and potentially modify it prior to building the main flake.
- We also have the option of testing new filesystem related features such as impermanence, Secure Boot, TPM2, Encryption, etc in a light weight environment prior to finalizing the main flake.

## Assumptions

The installer and instructions here assume that a _private_ nix-secrets repository is in use in conjunction with the nix-config _and_ the nix-secrets repo is structured to use shared secrets as well as host-specific secrets. Reference the _complex_ branch of the [nix-secrets-reference](https://github.com/EmergentMind/nix-secrets-reference) repository for an example of the expected structure as well as the article on [NixOS Secrets Management](https://unmovedcentre.com/posts/secrets-management/) to learn more.

For users new to Nix and NixOS it may be worth noting that because this script is installing NixOS, the usual [NixOS requirements](https://nixos.org/download/#nixos-iso) apply.

## Generating a custom NixOS ISO

We recommend using a custom ISO similar to what is defined in `nix-config/hosts/nixos/iso`. The official minimal NixOS iso has historical omitted some basic tty utilities that are expected by the installer scripts. The config for the ISO used in nix-config are similarly light-weight to [`nixos-installer/flake.nix`](flake.nix).

To generate the ISO, simply run `just iso` from the root of your `nix-config` directory. The resulting .iso file will be saved to `nix-config/result/iso/foo.iso`. A symlink to the file is also created at `nix-config/latest.iso`. The filename is time stamped for convenient reference when frequently trying out different ISOs in VMs. For example, `nixos-24.11.20250123.035f8c0-x86_64-linux.iso`.

If you are installing the host to a VM or remote infrastructure, configure the machine to boot into the .iso file.

If you are installing on a bare metal machine, write the .iso to a USB device. You can generate the iso and write it to a device in one command, using `just iso /path/to/usb/device`.

## Requirements for installing a new host

### Pre-installation steps:

1. Add `nix-config/hosts/nixos/[hostname]/` and `nix-config/home/[user]/[hostname].nix` files. You must declare the configuration settings for the target host as usual in your nix-config.
   Be sure to specify the device name (e.g. sda, nvme0n1, vda, etc) you want to install to along with the desired `nix-config/hosts/common/disks` disko spec.

   If needed, you can find the device name on the target machine itself by booting it into the iso environment and running `lsblk` to see a list of the devices. Virtual Machines often using a device called `vda`.
2. Add a `newConfig` entry for the target host in `nix-config/nixos-installer/flake.nix`, passing in the required arguments as noted in the file comments.
3. If you are planning to use the `backup` module on the target host, you _must_ temporarily disable it in the target host's config options until bootstrapping is complete. Failure to disable these two modules, will cause nix-config to look for the associated secrets in the new `[hostname].yaml` secrets file where they have not yet been added, causing sops-nix to fail to start during the build process. After rebuilding, we'll add the required keys to secrets and re-enable these modules.
    For example:
    ```nix
    # nix-config/hosts/nixos/guppy/default.nix
    #--------------------

    # ...
       # The back module is enabled via a services option. Set it to false.
        services.backup = {
            enable = false;
            # ...
        };
       #...
    ```

#### A note about secrets

There are different ways to set up secrets for a new target host. Some are more involved than others but they _all_ require some level of manual entry.
The installer script automates many of the required steps and therefore we will only describe the process of relying on that automation and making required manual entries near the end of the installation process.

In brief, the script will:

- create a host-specific age key pair
- create a host-specific user age key pair for the primary user
- create a `nix-secrets/sops/[hostname].yaml` secrets file with the user age private key (the host age private key is always derived from the host ssh key and therefore does not need to be stored in secrets)
- update the `.sops.yaml` file with:
    - public age keys entries for both the host and user
    - update the `creation_rules` for `shared.yaml` with the host and user age keys for the target host.
    - create a new `creation_rules` entry for `[hostname].yaml` specifying that the secrets file can be encrypted and decrypted by the primary user and host of both the target host _AND_ the host from which the installation script is being executed. This is important because until the target host has been fully bootstrapped, its `[hostname].yaml` must be accessible by something.

        For example, a host `ghost` running the installer script on target host `guppy` will result in the following sops `creation_rules` entry in `.sops.yaml`:

        ```yaml
            - path_regex: guppy\.yaml$
              key_groups:
                 - age:
                    - *ta_guppy
                    - *guppy
                    - *ta_ghost
                    - *ghost
        ```

As mentioned, the time for manual steps will be noted below.

## Requirements for installing an existing nix-config host on a new machine

Prior to installing an existing host config onto a new machine you likely only need to ensure that the `nix-config//hosts/nixos/[hostname]/default.nix`specific the correct disk device for disko.

Your existing config should already have a `hardware-configuration.nix` and a functioning compliment of sops secrets and sops creation rules. Therefore, many of the steps presented by the script can be safely skipped. The applicable steps will be noted below.

If you haven't already, add a `newConfig` entry for the target host in `nix-config/nixos-installer/flake.nix`, passing in the required arguments as noted in the file comments.

## Installation Steps

### 0. VM setup (optional)

This is only relevant if you are _not_ installing the target host on bare metal.

- Disk size: a decent _minimum_ disk size without swap is 25GB to accommodate for multiple generations on a testing machine.
     If you are using swap, remember that the space will come from the main disk you allocated for the VM so be sure to allocate enough _additional_ main disk space to accommodate your swap size needs.
     For example, if you need 50GB of storage for you machine and you also specified a swapsize of 8GB in nix-config, then allocate 48GB for the VMs disk size.
- You _must_ set up the hypervisor firmware to use UEFI instead of BIOS or the VM will fail to boot into the minimal-configuration.
    When creating the VM using virtmanager, you must select "Customize configuration before install" during step 5 of 5, and then change BIOS to UEFI on the next screen.
- For the CD/DVD-ROM source path select the custom iso file.
- Ensure the boot order is sane for automated reboots. For example, on VirtManager, set `VirtIO Disk 1` ahead of `SATA CDROM`, ensure both are checked, and also check `Enable boot menu` so that you can easily override the boot order on reboot if need be.

NOTE: If you encounter installation problems during reboot into the minimal-configuration, refer to [Troubleshooting](#troubleshooting) as there are a couple of different causes.

### 1. Initial boot

Boot the target machine into the NixOS ISO environment.

If necessary, note the IP address of the machine by running `ip a`.

### 2. Run the bootstrap script

On the source machine where nix-config already resides, run the following command from the root of `nix-confg`.

```bash
./scripts/bootstrap-nixos.sh -n [hostname] -d [destination]
```

Replace `[hostname]` with the name of the target host you are installing.
Replace `[destination]` with the location of the target machine.
Be sure to specify `--impermanence` if necessary. Use `--debug` if something goes wrong...

This is an example of running the script from `nix-config` base folder installing on a VM (`guppy`) with the `--debug` flag enabled:

```bash
./scripts/bootstrap-nixos.sh -n guppy -d=192.168.122.29 --debug
```

The script will give you several yes/no or no/yes questions. The questions are fairly self explanatory but we'll go through them here and make some notes that will be valuable depending on whether you are bootstrapping a new or existing host.


1. "Run nixos-anywhere installation?" default yes - This initiates installation of the minimal-config environment.
    1. "Manually set luks encryption passphrase?" default no - if you are using LUKS, say "y" and enter a temporary password when prompted. Disko will use for setting up LUKS and you can change it when installation is complete.
    2. "Generate a new hardware config for this host? Yes if your nix-config doesn't have an entry for this host." default no - Say yes only for new hosts that don't have a premade `hardware-configuration.nix`
    3. "Has your system restarted and are you ready to continue? (no exits)" - This is important. Nixosanywhere, will report the target host as available prior to it being fully rebooted. Wait until the target host prints a log in prompt before saying yes.
2. "Generate host (ssh-based) age key?" default yes - usually only needed for new hosts
3. "Generate user age key?" default yes - usually only needed for new hosts
4. "Add ssh host fingerprints for git{lab,hub}?" default yes - this will setup the full nix-config accessing nix-secrets as an input during the next steps
5. "Do you want to copy your full nix-config and nix-secrets to $target_hostname?" default yes - copies the source of both repos from the source machine to the target machine, faster than cloning from github/lab
    1. "Do you want to rebuild immediately?" default yes - builds the full config
6. "Do you want to commit and push the generated hardware-configuration.nix for $target_hostname to nix-config?" default yes - This will _only_ be presented if you said yes to question 1.2 and will push the file to your repo with an appropriate commit message.

Note: these questions are largely in place to allow subsequent running of the script when errors are encountered without being required to start from the very beginning again. For example, if you get all the way to step 5.1 and there was a problem with your final config for the target host that causes a build failure, you can fix the issue on your source host, rerun the script, skip through all of the questions until 5, and then pick up where you left off.


On completion, the script should end with a "Success!" message.

Depending on your host, the following post-install steps may not be required.

### 3. Post install steps for LUKS (optional)

#### Change LUKS2's passphrase if you entered a temporary passphrase during bootstrap

```bash
# when entering /path/to/dev/ you must specify the partition (e.g. /dev/nvmeon1p2)
# test the old passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

# change the passphrase
sudo cryptsetup luksChangeKey /path/to/dev/

# test the new passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/
```

#### Enroll yubikeys for touch-based unlock
Enable yubikey support:

NOTE: This requires LUKS2 (use cryptsetup luksDump /path/to/dev/ to check)

```bash
sudo systemd-cryptenroll --fido2-device=auto /path/to/dev/
```

You will need to do it for each yubikey you want to use.

#### Update the unlock passphrase for secondary drive unlock
If you passed the `--luks-secondary-drive-labels` arg when running the bootstrap script, it automatically created a `/luks-secondary-unlock.key` file for you using the passphrase you specified during bootstrap.
If you used a temporary passphrase during bootstrap, you can update the secondary unlock key by running the following command and following the prompts.

```bash
cryptsetup luksChangeKey /luks-secondary-unlock.key
```

#### If you forgot to use the `--luks-secondary-drive-labels` arg during bootstrap but need to set it up

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
example:
```nix
{
   environment.etc.crypttab.text = ''
    cryptextra UUID=569e2951-1957-4387-8b51-f445741b02b6 /luks-secondary-unlock.key
  ''
}
```

With this approach, the secondary drive is unlocked just before the boot process completes, without the need to enter its password.
The secondary drive will be unlocked and made available under /dev/mapper/cryptstorage for mounting.

### 4. Enable `backup` module (optional)

Enable the backup module in the target host's config file. For example:

    ```nix
    # nix-config/hosts/nixos/guppy/default.nix
    #--------------------

    # ...
        services.backup = {
            enable = true;
            # ...
        };
       #...
    ```

You will, of course, need to declare additional backup options for the module to function correctly.

### 5. Rebuild (optional)

If you did any of the steps from 3 through 5, you will need to rebuild for the changes to take effect. Run `just rebuild` from the `nix-config` directory on the new host.

### 6. Everything else (optional)

Here you should have a fully working system, but here are some common tasks you may need to do for a "daily-driver" machine:

- Recover any backup files needed
  - .mozilla
  - syncthing
- Manually set syncthing username/password
- Run any commonly used apps and perform
    - firefox and initiate sync
    - protonvpn
    - Re-link signal-desktop
- Login to spotify

## Troubleshooting

### Rebooting a VM into the minimal-config environment hangs indefinitely on "booting in to hard disk..."

There are two know causes for this issue:

1. The VM __must__ be created with the hypervisor firmware set to UEFI instead of BIOS. You will likely have to re-create the VM as this can't be changed after the fact.

2. The `hardware-configuration.nix` file may not have the required virtual I/O kernel module. Depending on the VM device type you will need to add either `virtio_pci` or `virtio_scsi` to the list of `availableKernelModules` in the host's `hardware-configuration.nix`
   For example:
   ```nix
   # nix-config/hosts/nixos/guppy/hardware-configuration.nix
   # -------------------

    # ...
       boot.initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    # ...
   ```

### Activation script snippet 'setupSecrets' failed - /run/secrets/keys/age: is a directory

This issue may be encountere when running the bootstrap script to update a host that had been previously installed with an older variant of nix-secrets where the age keys for all hosts were stored as "keys: age: [hostname]: [keydata]" where as now, because we're using host-specific secrets, the structure is "keys: age: [keydata]".

The failure will occur will occur near the end of the build output and will not display as an error in red.

```bash
...
sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint age1ee6shkrhqg0n84n3ksjays6h5klxv2xmhn5uksq9qvsxd079cvdql7tyk8
/nix/store/chvwxir82c2mf99961qyf9hfqjq76g02-sops-install-secrets-0.0.1/bin/sops-install-secrets: cannot request units to restart: read /run/secrets/keys/age: is a directory
Activation script snippet 'setupSecrets' failed (1)
Failed to run activate script
...
```

To resolve the issue, run `sudo rm -r /run/secrets/keys/age` on the target host and then rebuild.
