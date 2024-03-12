# Troubleshooting

[README](../README.md) > Troubleshooting

## TOC

- [The user systemd session is degraded](#the-user-systemd-session-is-degraded)
- [Pre-commit shit](#pre-commit-shit)
- [sops](#sops)
- [couldn't find efi system partition](#couldnt-find-efi-system-partition)

---

## The user systemd session is degraded

This issue was encountered during a home-manager switch without any substantial changes to the config.
Including --refresh seemed to solve the problem: `home-manager switch --refresh --flake .#ta@grief`

If adding `--refresh` does not solve the issue, you can run `systemctl --user reset-failed` prior to runninng `home-manager switch --flake .#ta@grief`

Failure output below:

```bash
❯ home-manager switch --flake .#ta@grief
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
trace: warning: optionsDocBook is deprecated since 23.11 and will be removed in 24.05
Starting Home Manager activation
Activating checkFilesChanged
Activating checkLinkTargets
Activating writeBoundary
Activating linkGeneration
Cleaning up orphan links from /home/ta
Creating profile generation 114
Creating home file links in /home/ta
Activating batCache
No themes were found in '/home/ta/.config/bat/themes', using the default set
No syntaxes were found in '/home/ta/.config/bat/syntaxes', using the default set.
Writing theme set to /home/ta/.cache/bat/themes.bin ... okay
Writing syntax set to /home/ta/.cache/bat/syntaxes.bin ... okay
Writing metadata to folder /home/ta/.cache/bat ... okay
Activating installPackages
replacing old 'home-manager-path'
installing 'home-manager-path'
Activating onFilesChange
Activating reloadSystemd
The user systemd session is degraded:
  UNIT             LOAD   ACTIVE SUB    DESCRIPTION
● sops-nix.service loaded failed failed sops-nix activation

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
1 loaded units listed.
Attempting to reload services anyway...
Started sops-nix.service - failed

There are 128 unread and relevant news items.
Read them by running the command "home-manager news".
```

## pre-commit shit

```errorlog snip
      Downloaded rowan v0.12.6
       Compiling autocfg v1.1.0
       Compiling serde v1.0.193
    error: linker `cc` not found
      |
      = note: No such file or directory (os error 2)

    error: could not compile `serde` (build script) due to previous error
    warning: build failed, waiting for other jobs to finish...
    error: failed to compile `nixpkgs-fmt v1.3.0 (/home/ta/.cache/pre-commit/repoqqkxe5ls)`, intermediate artifacts can be found at `/home/ta/.cache/pre-commit/repoqqkxe5ls/target`.
    To reuse those artifacts with a future compilation, set the environment variable `CARGO_TARGET_DIR` to that path.
    Check the log at /home/ta/.cache/pre-commit/pre-commit.log
```

Slightly different issue: <https://github.com/mozilla/nixpkgs-mozilla/issues/82>

seems to be because rust isn't installed as expected by pre-commit and isn't already available on my machine.

Further searching leads to this thread: https://github.com/numtide/devshell/issues/16
which has a solid argument about pre-commit being too late and looking for a solution that would shift format tooling left. Towars the end of the threat (which is dated May 30th, 2022 as of this entry on Dec 21,2023) there is a potential solution with treefmt.

TODO Needs further investigation to determine if this is a suitable solution.
NOTE needed to run `pre-commit uninstall` for now so it wouldn't be looking for .precommit.config.yml
will need to `pre-commit install` again when the time comes

## SOPS

When editing a secrets file via `sops example/path/secrets.yaml` you may encounter an error on save and exit such as the following:

```bash
$ sops hosts/common/secrets/secrets.yaml
[CMD]	ERRO[0149] Could not load tree, probably due to invalid syntax. Press a key to return to the editor, or Ctrl+C to exit.  error="Error unmarshaling input YAML: yaml: line 2: could not find expected ':'"
```

The following will cause you grief:

```yaml
example-secret-key: |
    -----START PRIVATE KEY----
[some data]
-----END PRIVATE KEY----
```

You MUST align the data properly or you will encounter errors
For example:

```yaml
example-secret-key: |
  -----START PRIVATE KEY----
  [some data]
  -----END PRIVATE KEY----
```

## Couldnt' find EFI system partition

This issue was encountered shortly after completing the [first install](./Firstinstall.md) and making some trying to get some base level stuff tweaked the first day:

I think this was caused by a bootloader mismatch or something
I completely fucked the machine (gusto) and I ended up paving.

```bash
[nix-shell:~/src/nix-config]$ sudo nixos-rebuild switch --flake .#gusto
building the system configuration...
File system "/boot" is not a FAT EFI System Partition (ESP) file system.
systemd-boot not installed in ESP.
No default/fallback boot loader installed in ESP.
Traceback (most recent call last):
  File "/nix/store/d1i79l65v1zvvx5rrcnh5dhnzmppkwq3-systemd-boot", line 344, in <module>
    main()
  File "/nix/store/d1i79l65v1zvvx5rrcnh5dhnzmppkwq3-systemd-boot", line 332, in main
    install_bootloader(args)
  File "/nix/store/d1i79l65v1zvvx5rrcnh5dhnzmppkwq3-systemd-boot", line 270, in install_bootloader
    raise Exception("could not find any previously installed systemd-boot")
Exception: could not find any previously installed systemd-boot
warning: error(s) occurred while switching to the new configuration

[nix-shell:~/src/nix-config]$ nixos-install --flake .#gusto
mount point /mnt doesn't exist

[nix-shell:~/src/nix-config]$ mount /boot
mount: /boot: can't find in /etc/fstab.

[nix-shell:~/src/nix-config]$ bootctl status
Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi.
Alternatively, use --esp-path= to specify path to mount point.
WARNING: terminal is not fully functional
Press RETURN to continue
System:
      Firmware: UEFI 2.31 (American Megatrends 4.654)
 Firmware Arch: x64
   Secure Boot: disabled
  TPM2 Support: no
  Boot into FW: supported

Current Boot Loader:
      Product: systemd-boot 253.6
     Features: ✓ Boot counting
               ✓ Menu timeout control
               ✓ One-shot menu timeout control
               ✓ Default entry control
               ✓ One-shot entry control
               ✓ Support for XBOOTLDR partition
               ✓ Support for passing random seed to OS
               ✓ Load drop-in drivers
               ✓ Support Type #1 sort-key field
               ✓ Support @saved pseudo-entry
               ✓ Support Type #1 devicetree fie
               ✗ Enroll SecureBoot keys
               ✗ Retain SHIM protocols
               ✓ Boot loader sets ESP information
          ESP: /dev/disk/by-partuuid/611513dc-a9bb-d744-924d-e371c64896f5
         File: └─/EFI/systemd/systemd-bootx64.efi

Random Seed:
 System Token: set

Boot Loaders Listed in EFI Variables:
        Title: Linux Boot Manager
           ID: 0x0000
       Status: active, boot-order
    Partition: /dev/disk/by-partuuid/611513dc-a9bb-d744-924d-e371c64896f5
         File: └─/EFI/systemd/systemd-bootx64.efi

        Title: UEFI OS
           ID: 0x0004
       Status: active, boot-order
    Partition: /dev/disk/by-partuuid/611513dc-a9bb-d744-924d-e371c64896f5
         File: └─/EFI/BOOT/BOOTX64.EFI


[nix-shell:~/src/nix-config]$ nixos-rebuild boot --install-bootloader

```

---

[Return to top](#troubleshooting)

[README](../README.md) > Troubleshooting
