# Roadmap of TODOs

[README](../README.md) > Roadmap of TODOs

## Short Term

- Stage 3.1

  - ~~research and design~~
  - ~~lab testing~~
  - ~~add msmtp email and host to secrets~~
  - ~~refinement and confirmation testing~~
  - ~~implement across hosts~~
  - documentation
    - ~~part 1~~
    - ~~part 2~~
    - ~~part 3~~
    - part 4

    - link installer docs to main readme

- Stage 3.2
  - luks
  - lanzaboot

- Video series

  - ~~planning~~
  - ~~storyboard~~
  - ~~assets~~
  - recording
    - ~~part 3~~
    - part 4
  - production
    - ~~part 3~~
    - part 4

- New tools to integrate
  - copyq
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

#### 3. Squeaky Clean - Current

Introduce declarative partitioning, custom iso generation, automated machine setup, and impermanence among other improvements that aim to create a cleaner environment.

##### 3.1 automate nixos installation

- ~~nixos-anywhere~~
- ~~declarative partitioning and formatting via disko~~
- ~~light-weight bootstrap flake for basic, pre-secrets install~~
- ~~custom iso generation~~
- ~~automated bootstrap script~~

##### 3.2 secure boot and drive encryption

- luks  https://wiki.nixos.org/wiki/Yubikey_based_Full_Disk_Encryption_(FDE)_on_NixOSa
- lanzaboote

Stage 1 with systemd info
- https://github.com/ElvishJerricco/stage1-tpm-tailscale
- https://youtu.be/X-2zfHnHfU0?si=HXCyJ5MpuLhWWwj3

##### 3.3 impermanence

- declare what needs to persist
- enable impermanence

  Need to sort out how to maintain /etc/ssh/ssh_host_ed25519_key and /etc/ssh/ssh_host_ed25519_key.pub

  !! Some of this needs heavy assessment and consideration given the assumed reliance on theoretical tooling like flake-parts, which is a tangential extension of flakes (which is in fact _still_ experimental)
  If there is a way to incorporate these ideas without adopting additional experimentation that's okay but otherwise, avoid.

##### 3.x Extras

- ~~Make use of configLib.scanPaths~~
- ~~look for better syntax options to shorten just recipes~~
- Decided to just re-eanble nix-fmt ~~update nix-fmt to nixfmt-rfc-style (including pre-commit) since it will be the standard for nix packages moving forward~~
- ~~update sops to make use of per host age keys for home-manager level secrets~~
- automatic scheduled sops rotate
- don't bother ~~maybe rename pkgs -> custom_pkgs and modules -> custom_modules~~
- Enable git signing in home/ta/common/core/git.nix using nix-secrets
- Investigate outstanding yubikey FIXMEs
- Potentially yubiauth and u2f for passwordless sudo
  FidgetingBits still encounter significant issues with this when remoting
- Confirm clamav scan notification
  - check email for clamavd notification on ~/clamav-testfile. If yes, remove the file
  - check if the two commented out options in hosts/common/options/services/clamav.nix are in stable yet.

##### Stage 3 References non-temporary
#### 4. Laptops and better GUI experience

Add laptop support to the mix to handle stuff like power, lid state, wifi, and the like.
Also start adding more to the GUI experience for machines that are meant for more than browser streaming.

- hyprland binds
- hyprland essentials
- laptop utils
- more desktop utils and customization
  - set up copyq clipboard mgr
  - dig into better kitty and zsh usage
  - better linting and fixing in vscode and vim
  - look at https://github.com/dandavison/delta
- gui dev
  - host specific colours via stylix or nix-colors
- dualboot for trades?

##### Stage 4 References

- [stylix](https://github.com/danth/stylix)
- [nix-colors](https://github.com/Misterio77/nix-colors)

#### 5. Ghost

- ricing
  - plymouth
  - grub - https://www.gnome-look.org/browse?cat=109&ord=latest
    - maybe rEFInd
  - greetd
  - p10k - consider config so that line glyphs don't interfere with yanking
  - fonts - https://old.reddit.com/r/vim/comments/fonzfi/what_is_your_favorite_font_for_coding_in_vim/
  - centralize color palette
  - dunst
  - airline
- dig into fzf and telescope
- hotkey for sleeping monitors (all or game mode)
- check out ananicy - hold over todo from arch but there is a nixos pkg here https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query=ananicy
- disk usage notifier

#### 6. Witty name

##### 6.1 automate config deployment

- Per host branch scheme
- Automated machine update on branch release
- Handle general auto updates as well

##### 6.2 script cleaning

- Consider nixifying bash scripts (see refs below)
- Overhaul just file
  - clean up
  - add {{just.executable()}} to just entries
  - explore direnv

##### 6.3 reduce duplication and modularize

- Refactor nix-config to use more extensive specialArgs and extraSpecial Args for common user and host settings
- Re-implement modules to make use of options for enablement

##### 6.x Extras

- Look at re-enabling CI pipelines. These were disabled during stage 2 because I moved to inputing the private nix-secrets repo in flake.nix. Running nix flake check in a gitlab pipeline now requires figuring out access tokens. There were higher priorities considering the check can be run locally prior to pushing.

#### 7. Raspberry Pi

#### 8. Using Nix package manager on \*

---

[Return to top](#roadmap-of-todos)

[README](../README.md) > Roadmap of TODOs
