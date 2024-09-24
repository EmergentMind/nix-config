# Notes for LUKS and Impermanence

## LUKS stuff

fidgetingbits:
Although I use a nix-secrets repo that has sops, in order to do LUKS unlock over ssh I need host keys that aren't
able to be stored in sops. See here. The solution
is to use git-agecrypt. However, afaict this can't be exposed through nix-secrets repo, which means that evaluation-time
NOTE going to have to do this once I've got NixOS on bare metal because I can't seem to redirect yubikey devices to the VM
;w
secrets must be stored in the local repo.
his is how I setup:

```bash
git-agecrypt init
ssh-keygen -t ed25519 -N "" -f hosts/ooze/initrd_ed25519_key
git-agecrypt config add -r "$(cat ~/.ssh/id_yubikey.pub)" -p hosts/ooze/initrd_ed25519_key
```

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
```### Change LUKS2's passphrase and enroll yubikeys

1. Change the temporary passphrase ("passphrase") set by `bootstrap-nixos.sh` to a permanent and secure passphrase. This will act as a manual fallback if you also complete step 2.

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

3. Repeat step 2 for each yubikey you want to use.aiting-10-seconds-for-luks-device/33423

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

### Change LUKS2's passphrase and enroll yubikeys

1. Change the temporary passphrase ("passphrase") set by `bootstrap-nixos.sh` to a permanent and secure passphrase. This will act as a manual fallback if you also complete step 2.

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
