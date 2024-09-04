# Roadmap of TODOs

[README](../README.md) > Roadmap of TODOs

## Short Term

- update docs in nix-secrets
- ~~add private but unencrypted vars to nix-secrets~~
- 4.1 - Prep
  - setup borg module
    - ~~add module~~
    - config refinement
    - testing
  - hyprland prep
    - map i3 binds to hyprland binds
    - config hyprland essentials
    - test on Grief
  - migrate dotfiles to nix-config
    - start with raw dump into nix extras for now
    - connect to grief first to test each one individually
  - ghost modules
    - host
      - config mounting extra drives
    - home
    - nixos-installer
  - change over and recovery plan
    - audit main drive on ghost for missed items
    - final grief tests
    - push


- New tools to integrate
  - atuin - https://github.com/atuinsh/atuin
  - dh
  - copyq - https://hluk.github.io/CopyQ/
  - du-dust
  - syncthing - refer to https://nitinpassa.com/running-syncthing-as-a-system-user-on-nixos/

- New tools to try
  - wezterm
  - tmux or zellij

## Long Term

### Project Stages

#### 1. Core - Completed: 2023.12.24

Build up a stable config using grief lab. The focus will be on structure,
nix-config automation, and core tty that will be common on all machines.

- ~~Basic utility shell for bootstrapping~~
- ~~Core host config common to all machines~~
  - ~~garbage collection~~
  - ~~clamav~~
  - ~~msmtp notifier~~
  - ~~ability to import modular options~~
- ~~Core home-manager config for primary user~~
  - ~~cli configs~~
  - ~~nvim config~~
  - ~~ability to import modular options~~
- ~~Repository based secrets management for local users, remote host connection, and repository auth~~
- ~~Ability to consistently add new hosts and users with the core settings~~
- ~~Basic automation for rebuilds~~
- ~~Basic CI testing~~

#### 2. Multihost, multiuser with basic GUI - Completed: 2024.02.18

This stage will add a second host machine, gusto (theatre). To effectively used gusto, we'll need to introduce gui elements such as a desktop, basic QoL tools for using the desktop, and some basic gui applications to play media, including the requisite audio/visual packages to make it all work.

- ~~Add a media user specifically for gusto (autolog that one)~~
- ~~Document and tweak steps to deploy to new host~~
- ~~Simple desktop - add visual desktop and a/v elements as common options~~
- ~~Stable windows manager environment~~
- ~~Stable audio~~
- ~~Stable video~~
- ~~Auto-upgrade~~
- ~~Better secrets management~~
  - ~~private repo for secrets~~
  - ~~personal documentation for secrets management, i.e. README for nix-secrets private repo~~
  - ~~public documentation for secrets management, i.e. how to use this repo with the private repo~~
- DEFERRED - Potentially yubiauth and u2f for passwordless sudo
- ~~Review and complete applicable TODO sops, TODO yubi, and TODO stage 2~~
- ~~Deploy gusto~~

#### 3. Installation Automation and drive encryption - Completed: 2024.08.08

Introduce declarative partitioning, custom iso generation, install automation, and full drive encryption. This stage was also initially intended to add impermanence and several other improvements aimed at keeping a
cleaner environment. However, automation took substantially longer than anticipated and I need to start using NixOS as a daily driver sooner than later. Being spread across two distros and different config paradigms while putting 99% of the effort into the new distro/config is becoming unsustainable. As such, several features have been deferred until later stages.

##### 3.1 automate nixos installation

- ~~nixos-anywhere~~
- ~~declarative partitioning and formatting via disko~~
- ~~light-weight bootstrap flake for basic, pre-secrets install~~
- ~~custom iso generation~~
- ~~automated bootstrap script~~

##### 3.2 drive encryption

Local decryption only for now. Enabling remote decryption while working entirely from VMs is beyond my current abilities.

- ~~LUKS full drive encryption~~

##### 3.x Extras

- ~~Make use of configLib.scanPaths~~
- ~~look for better syntax options to shorten just recipes~~
- Decided to just re-enable nix-fmt ~~update nix-fmt to nixfmt-rfc-style (including pre-commit) since it will be the standard for nix packages moving forward~~
- ~~update sops to make use of per host age keys for home-manager level secrets~~
- don't bother ~~maybe rename pkgs -> custom_pkgs and modules -> custom_modules~~
- ~~Enable git ssh signing in home/ta/common/core/git.nix~~

DEFERRED:

- Investigate outstanding yubikey FIXMEs
- Potentially yubiauth and u2f for passwordless sudo
  FidgetingBits still encounter significant issues with this when remoting
- Confirm clamav scan notification
  - check email for clamavd notification on ~/clamav-testfile. If yes, remove the file
  - check if the two commented out options in hosts/common/options/services/clamav.nix are in stable yet.

#### 4. Ghost

##### 4.1 Prep

- setup borg module
- hyprland prep
  - map i3 binds to hyprland binds
  - config hyprland essentials
  - test on Grief
- migrate dotfiles to nix-config
  - start with raw dump into nix extras for now
  - connect to grief first to test each one individually
- ghost modules
  - host
    - config mounting extra drives
  - home
  - nixos-installer
- change over and recovery plan
  - audit main drive on ghost for missed items
  - final grief tests
  - push

##### 4.2 Change over

- install nixos on Ghost
- verify drives
- verify critical apps and services functionality
- verify backups

##### 4.3 Get comfortable

- setup and enable hyprland
- reestablish workflow

##### 4.3.x Extras

- Investigate outstanding yubikey FIXMEs
- yubiauth and u2f for passwordless sudo
  - FidgetingBits still encounter significant issues with this when remoting
- Confirm clamav scan notification
  - check email for clamavd notification on ~/clamav-testfile. If yes, remove the file
  - check if the two commented out options in hosts/common/options/services/clamav.nix are in stable yet.
- basic themeing via stylix or nix-colors
- dig into fzf and telescope
- hotkey for sleeping monitors (all or game mode)
- disk usage notifier
- check out ananicy - hold over todo from arch but there is a nixos pkg here https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query=ananicy
- more desktop utils and customization
  - set up copyq clipboard mgr
  - dig into better kitty and zsh usage
  - better linting and fixing in vscode and nvim
  - look at https://github.com/dandavison/delta

##### Stage 4 References

- [stylix](https://github.com/danth/stylix)
- [nix-colors](https://github.com/Misterio77/nix-colors)

#### 5. Laptops

Add laptop support to the mix to handle stuff like power, lid state, wifi, and the like.

- laptop utils

#### 6. Squeaky clean

##### 6.x impermanence

- declare what needs to persist
- enable impermanence

  Need to sort out how to maintain /etc/ssh/ssh_host_ed25519_key and /etc/ssh/ssh_host_ed25519_key.pub

##### 6.x remote luks decryption

The following has to happen on bare metal because I can't seem to get the yubikey's to redirect to the VM for use with git-agecrypt.

- Remote LUKS decrypt over ssh for headless hosts
  - need to set up age-crypt keys because this happens before sops and therefore we can't use nix-secrets
  - add initrd-ssh module that will spawn an ssh service for use during boot

##### 6.x automate config deployment

- Per host branch scheme
- Automated machine update on branch release
- Handle general auto updates as well

##### 6.x script cleaning

- Consider nixifying bash scripts (see refs below)
- Overhaul just file
  - clean up
  - add {{just.executable()}} to just entries
  - explore direnv

##### 6.x reduce duplication and modularize

- Refactor nix-config to use more extensive specialArgs and extraSpecial Args for common user and host settings
- Re-implement modules to make use of options for enablement

##### 6.x secure boot

- lanzaboote https://github.com/nix-community/lanzaboote

Some stage 1 with systemd info for reference (not specific to lanzaboote)

- https://github.com/ElvishJerricco/stage1-tpm-tailscale
- https://youtu.be/X-2zfHnHfU0?si=HXCyJ5MpuLhWWwj3

##### 6.x Extras

- automatic scheduled sops rotate
- Look at re-enabling CI pipelines. These were disabled during stage 2 because I moved to inputting the private nix-secrets repo in flake.nix. Running nix flake check in a gitlab pipeline now requires figuring out access tokens. There were higher priorities considering the check can be run locally prior to pushing.
- move Gusto to disko
- revisit scanPaths. Usage in hosts/common/core is doubled up when hosts/common/core/services is imported. Options are: declare services imports individually in services/default.nix, move services modules into parent core directory... or add a recursive variant of scanPaths.

##### Stage 6 references

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

#### 7. Ricing

- gui dev
  - host specific colours via stylix or nix-colors

- plymouth
- grub - https://www.gnome-look.org/browse?cat=109&ord=latest
  
- maybe rEFInd
- greetd
- p10k - consider config so that line glyphs don't interfere with yanking
- fonts - https://old.reddit.com/r/vim/comments/fonzfi/what_is_your_favorite_font_for_coding_in_vim/
- centralize color palette
- dunst
- airline

#### 8. tbd

---

[Return to top](#roadmap-of-todos)

[README](../README.md) > Roadmap of TODOs
