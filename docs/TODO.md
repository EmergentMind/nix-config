# Roadmap of TODOs

[README](../README.md) > Roadmap of TODOs

## 1. Core - Completed: 2023.12.24

Build up a stable config using grief lab. The focus will be on structure,
nix-config automation, and core tty that will be common on all machines.

- [x] Basic utility shell for bootstrapping
- [x] Core host config common to all machines
  - [x] garbage collection
  - [x] clamav
  - [x] msmtp notifier
  - [x] ability to import modular options
- [x] Core home-manager config for primary user
  - [x] cli configs
  - [x] nvim config
  - [x] ability to import modular options
- [x] Repository based secrets management for local users, remote host connection, and repository auth
- [x] Ability to consistently add new hosts and users with the core settings
- [x] Basic automation for rebuilds
- [x] Basic CI testing

## 2. Multihost, multiuser with basic GUI - Completed: 2024.02.18

This stage will add a second host machine, gusto (theatre). To effectively used gusto, we'll need to introduce gui elements such as a desktop, basic QoL tools for using the desktop, and some basic gui applications to play media, including the requisite audio/visual packages to make it all work.

- [x] Add a media user specifically for gusto (autolog that one)
- [x] Document and tweak steps to deploy to new host
- [x] Simple desktop - add visual desktop and a/v elements as common options
- [x] Stable windows manager environment
- [x] Stable audio
- [x] Stable video
- [x] Auto-upgrade
- [x] Better secrets management
  - [x] private repo for secrets
  - [x] personal documentation for secrets management, i.e. README for nix-secrets private repo
  - [x] public documentation for secrets management, i.e. how to use this repo with the private repo
- [x] Review and complete applicable TODO sops, TODO yubi, and TODO stage 2
- [x] Deploy gusto

DEFERRED:

- [>] Potentially yubiauth and u2f for passwordless sudo ## 3. Installation Automation and drive encryption - Completed: 2024.08.08

Introduce declarative partitioning, custom iso generation, install automation, and full drive encryption. This stage was also initially intended to add impermanence and several other improvements aimed at keeping a
cleaner environment. However, automation took substantially longer than anticipated and I need to start using NixOS as a daily driver sooner than later. Being spread across two distros and different config paradigms while putting 99% of the effort into the new distro/config is becoming unsustainable. As such, several features have been deferred until later stages.

### 3.1 automate nixos installation

- [x] nixos-anywhere
- [x] declarative partitioning and formatting via disko
- [x] light-weight bootstrap flake for basic, pre-secrets install
- [x] custom iso generation
- [x] automated bootstrap script

### 3.2 drive encryption

Local decryption only for now. Enabling remote decryption while working entirely from VMs is beyond my current abilities.

- [x] LUKS full drive encryption

### 3.x Extras

- [x] Make use of configLib.scanPaths
- [x] look for better syntax options to shorten just recipes
- [x] Decided to just re-enable nix-fmt  ~~update nix-fmt to nixfmt-rfc-style (including pre-commit) since it will be the standard for nix packages moving forward~~
- [x] update sops to make use of per host age keys for home-manager level secrets
- [-] don't bother ~~maybe rename pkgs -> custom_pkgs and modules -> custom_modules~~
- [x] Enable git ssh signing in home/ta/common/core/git.nix

DEFERRED:

- [>] Investigate outstanding yubikey FIXMEs
- [>] Potentially yubiauth and u2f for passwordless sudo
  [>] FidgetingBits still encounter significant issues with this when remoting
- [>] Confirm clamav scan notification
  - [>] check email for clamavd notification on ~/clamav-testfile. If yes, remove the file
  - [>] check if the two commented out options in hosts/common/options/services/clamav.nix are in stable yet.

## 4. Ghost - completed: 2024.10.21

Migrate primary box to NixOS

### 4.1 Prep

- [x] setup borg module
- [x] hyprland prep
- [x] migrate dotfiles to nix-config
- [x] ghost modules
- [x] change over and recovery plan

### 4.2 Change over

- [x] install nixos on Ghost
- [x] verify drives
- [x] verify critical apps and services functionality
- [x] enable backup
- [x] enable mediashare

### 4.3 Get comfortable

- [x] setup and enable hyprland basics
  - [x] hyprlock
  - [x] logout manager
  - [x] waypaper
  - [x] dunst
  - [x] rofi-wayland
- [x] reestablish workflow

### 4.3.x Extras

- [x] Investigate outstanding yubikey FIXMEs
- [x] yubiauth and u2f for passwordless sudo
- [x] Confirm clamav scan notification
  - [x] check email for clamavd notification on ~/clamav-testfile. If yes, remove the file
  - [x] check if the two commented out options in hosts/common/options/services/clamav.nix are in stable yet.
- [x] basic themeing via stylix or nix-colors
- [x] hotkey for sleeping monitors (all or non-primary)
- [x] set up copyq clipboard mgr

## 5. Refactoring and Refinement - completed: 2025.09.22
Some of the original parts of this stage have been split off to later stages because they are more Nice to Have at the moment.

### 5.1 Reduce duplication and modularize

- [x] Refactor nix-config to use more extensive specialArgs and extraSpecial Args for common user and host settings
- [x] Refactor from configVars to modularized hostSpec
- [>] Re-implement modules to make use of options for enablement. Deferred, nice to have

### 5.2 Refactor secrets

- [x] separate soft and hard secrets
- [x] per-host sops secrets
- [x] create example, public repo for nix-secrets

### 5.3 Bootstrap fix

- [x] Revise bootstrap script and roll in granular secrets hierarchy
- [x] Rewrite install steps

### 5.4 Tests

- [>] Re-enable CI pipeline. Deferred for now, dealing with nix-secrets is too much hassle
- [x] Write bats tests for helpers.sh

### 5.5 Starter repo

- [x] Set up separate, stripped-down and simplified nix-config for newcomers

### 5.x Extras

- [x] move Gusto to disko

## 6. Laptops and Refactored multiuser  - completed: 2025.11.22
Add laptop support to the mix to handle stuff like power, lid state, wifi, and the like.

### 6.1 Laptops
- [x] nixify genoa
- [x] add laptop utils

[#####](#####) 6.2 Refactor multiuser
- [x] refactor how multiuser works ala fidgetingbits' changes

## 7. QoL and Ricing 1

QoL
- [x] fix nvim/neo-tree default directory
- [ ] stop calendar notifications from stealing focus... sort of dealt with using 'noinitialfocus' dispatcher but it happens immediately after focus has already been stolen
- [x] move to niri... hyprland is pissing me off too often
  - [x] usable for daily driver
  - [x] parity with current state hyprland config
  - [/] refactor monitor toggling scripts
  - [ ] refactor for dynamic host handling. niri unfortunately uses .kdl which doesn't play well  with nixos currently so may be SoL for a while
        could consider using the niri flake but I'd prefer less reliance on someone else
- [ ] Monitors Module improvements
    - [ ] potentially integrate Kanshi (for wayland) and arandr (for x) to handle profiles based on the connected displays.
- [ ] Declarative audio output device for gusto if possible

Rice
- [/] ui dev
  - [x] ascendancy color set
    - [x] colors
    - [x] repo
    - [x] add to tinted gallery
  - [x] host specific colours (terminal in particular) via stylix
  - [/] centralize custom color palette: waiting for stylix to catchup to tinted-themes
- [ ] eww as a potential replacement to waybar
- [ ] ssh-motd
- [x] awww background service and random cycling
- [ ] plymouth
- [ ] grub - https://www.gnome-look.org/browse?cat=109&ord=latest
- [ ] rEFInd - Maybe?
- [-] ~~p10k~~ - decided on starship
- [x] starship cli prompt
  - [x] fix the stupid emoji font
- [x] sddm ~~or greetd~~
  - [~] fork silentsddm and add custom screens
- [x] font - decided on FiraMono
- [ ] dunst
- [ ] lualine
- [ ] wlogout

### Stage 7 References

- [stylix](https://github.com/danth/stylix)

## 8. Squeaky clean

### 8.1 Impermanence   - completed: 2026.02.20

- [x] declare what needs to persist
  - [x] Need to sort out how to maintain /etc/ssh/ssh_host_ed25519_key and /etc/ssh/ssh_host_ed25519_key.pub
  - [x] make sure to include `/luks-secondary-unlock.key` (will be handled by modules/nixos/disks)
- [x] enable impermanence

### Stage 8 references

Impermanence - These two are the references to follow and integrate. The primer list below is good review before diving into this:

- [blog- setting up my machines nix style](https://aldoborrero.com/posts/2023/01/15/setting-up-my-machines-nix-style/)
- [template repo for the above](https://github.com/aldoborrero/templates/tree/main/templates/blog/nix/setting-up-machines-nix-style)

Impermanence primer info

- [impermanence repo - an implementation of the below concept](https://github.com/nix-community/impermanence)
- [blog - erase your darlings](https://grahamc.com/blog/erase-your-darlings/)
- [blog - encrypted btrfs root with opt-in state](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
- [blog - setting up my new laptop nix style](https://bmcgee.ie/posts/2022/12/setting-up-my-new-laptop-nix-style/)
- [blog - tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
- [blog - tmpfs as home](https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/)

Migrating bash scripts to nix
- https://www.youtube.com/watch?v=diIh0P12arA and https://www.youtube.com/watch?v=qRE6kf30u4g
- Consider also the first comment "writeShellApplication over writeShellScriptBin. writeShellApplication also runs your shell script through shellcheck, great for people like me who write sloppy shell scripts. You can also specify runtime dependencies by doing runtimeInputs = [ cowsay ];, that way you can just write cowsay without having to reference the path to cowsay explicitly within the script"

## 9 Automatic microvms for agents - completed: 2026.07.27
- [x] network segregated, auto-starting microvm sandboxes for agent sessions

## 10 Improved network handling

- [ ] complete services.per-network-services
- [ ] add firewall module

## 11 Improving remote

### 11.1 Automate config deployment

- [ ] Per host branch scheme
- [ ] Automated machine update on branch release
- [ ] Handle general auto updates as well

### 11.2 Remote luks decryption

The following has to happen on bare metal because I can't seem to get the yubikey's to redirect to the VM for use with git-agecrypt.

- [ ] Remote LUKS decrypt over ssh for headless hosts
  - [ ] need to set up age-crypt keys because this happens before sops and therefore we can't use nix-secrets
  - [ ] add initrd-ssh module that will spawn an ssh service for use during boot

### 11.x Extras

- [ ] Automatic scheduled sops rotate
- [ ] Disk usage notifier
- [ ] Consider nixifying bash scripts (see refs below)
- [ ] Overhaul just file
  - [ ] add {{just.executable()}} to just entries
- [ ] revisit scanPaths. Usage in hosts/common/core is doubled up when hosts/common/core/services is imported. Options are: declare services imports individually in services/default.nix, move services modules into parent core directory... or add a recursive variant of scanPaths.


## 12 Secure boot

- [ ] lanzaboote https://github.com/nix-community/lanzaboote

Some stage 1 with systemd info for reference (not specific to lanzaboote)

- https://github.com/ElvishJerricco/stage1-tpm-tailscale
- https://youtu.be/X-2zfHnHfU0?si=HXCyJ5MpuLhWWwj3


## 13. TBD

- [ ] Nixify floater laptop

---

[Return to top](#roadmap-of-todos)

[README](../README.md) > Roadmap of TODOs
