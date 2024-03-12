# Roadmap of TODOs

[README](../README.md) > Roadmap of TODOs

## Short Term

- Stage 3.1

  - ~~research and design~~
    - ~~read nixos-anywhere and disko docs~~
    - ~~reference ryan4yin installer flake for ideas~~
    - ~~Map out order of operations for install~~
      1. ~~boot to installer on target machine~~
      2. ~~identify and verify drives to be targetted by disko~~
      3. ~~update the related disk-config.nix in the nix-config repo accordingly~~
      4. ~~install nixos using a lightweight install flake via nixos-anywhere~~
      - ~~see https://github.com/nix-community/nixos-anywhere-examples/blob/main/flake.nix and https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md for basic template example~~
      5. ~~deploy the full config for host~~
    - ~~build out basic ./nixos-installer~~
      - ~~flake.nix~~
      - ~~disk-config.nix~~
      - ~~README.md~~
      - ~~potentially a configuration.nix~~
  - ~~lab testing~~
  - add msmtp email and host to secrets
  - refinement and confirmation testing
    - modify install config to better represent somethign useful
    - test on guppy as part of full config
    - automation scripts
  - implement across hosts
  - docs
    - link installer docs to main readme

- Next video

  - ~~planning~~
  - ~~storyboard~~
  - assets
  - recording
  - production

- New tools to integrate
  - ~~zoxide~~
  - copyq
  - du-dust
  - syncthing

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

- nixos-anywhere
- declarative partitioning and formatting via disko
- light-weight bootstrap flake for basic install, pre-secrets install
- custom iso generation?

##### 3.2 automate config deployment

- Per host branch scheme
- Automated machine update on branch release

##### 3.3 reduce duplication

- Refactor nix-config to use specialArgs and extraSpecial Args for common user and host settings

##### 3.4 impermanence

- declare what needs to persist
- enable impermance

  Need to sort out how to maintain /etc/ssh/ssh_host_ed25519_key and /etc/ssh/ssh_host_ed25519_key.pub

  !! Some of this needs heavy assessment and consideration given the assumed reliance on theoretical tooling like flake-parts, which is a tangential extension of flakes (which is in fact _still_ experimental)
  If there is a way to incorporate these ideas without adopting additional experimentation that's okay but otherwise, avoid.

##### 3.5

- Migrate bash scripts (see refs below)
- Overhaul just file

##### 3.x Extras

- Rename pkgs -> custom_pkgs and modules -> custom_modules
- Enable git signing in home/ta/common/core/git.nix using nix-secrets
- Investigate outstanding yubikey FIXMEs
- Potentially yubiauth and u2f for passwordless sudo
  FidgetingBits still encounter significant issues with this when remoting
- Confirm clamav scan notification
  - check email for clamavd notification on ~/clamav-testfile. If yes, remove the file
  - check if the two commented out options in hosts/common/options/services/clamav.nix are in stable yet.
- Potentially re-enable CI pipelines. These were disabled during stage 2 because I moved to inputing the private nix-secrets repo in flake.nix. Running nix flake check in a gitlab pipeline now requires figuring out access tokens. There were higher priorities considering the check can be run locally prior to pushing.

##### Stage 3 References

- Migrating bash scripts to nix: https://www.youtube.com/watch?v=diIh0P12arA
  Consider also the first comment "writeShellApplication over writeShellScriptBin. writeShellApplication also runs your shell script through shellcheck, great for people like me who write sloppy shell scripts. You can also specify runtime dependencies by doing runtimeInputs = [ cowsay ];, that way you can just write cowsay without having to reference the path to cowsay explicitly within the script"

**Impermanence**
These two are the references to follow and integrate. The primer list below is good review before diving into this:

- [blog- setting up my machines nix style](https://aldoborrero.com/posts/2023/01/15/setting-up-my-machines-nix-style/)
- [template repo for the above](https://github.com/aldoborrero/templates/tree/main/templates/blog/nix/setting-up-machines-nix-style)

**Impermanence Primer**

- [impermanence repo - an implementation of the below concept](https://github.com/nix-community/impermanence)
- [blog - erase your darlings](https://grahamc.com/blog/erase-your-darlings/)
- [blog - encrypted btrfs roor with opt-in state](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
- [blog - setting up my new laptop nix style](https://bmcgee.ie/posts/2022/12/setting-up-my-new-laptop-nix-style/)
- [blog - tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
- [blog - tmpfs as home](https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/)

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
  - host specific colours via nix-colors
- dualboot for trades?

##### Stage 4 References

- [nix-colors](https://github.com/Misterio77/nix-colors) - consider using this for easy color scheming across hosts

#### 5. Ghost

- ricing
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

#### 6. Raspberry Pi

#### 7. Using Nix package manager on \*

---

[Return to top](#roadmap-of-todos)

[README](../README.md) > Roadmap of TODOs
