<div align="center">
<h1>
<img width="100" src="https://raw.githubusercontent.com/simple-icons/simple-icons/master/icons/nixos.svg" /> <br>
</h1>
</div>

# EmergentMind's Nix-Config

>Where am I?
>>You're in a rabbit hole.
>
>How did I get here?
>>The door opened; you got in.

Somewhere between then and now you discovered this cairne in the fog. I hope it is useful in some way. Inspiration, reference, or whatever you're looking for.

This is written perhaps as more of a reminder for myself as it is for you, but then again you could be future me or maybe past me stuck in a strange loop...

```bash
$ whoami
error: entity unknown or undefined
```

Steady...

The way out, is through.

## :closed_book: Table of Contents

* [Feature Highlights](#sparkles-feature-highlights)
* [Roadmap of TODOs](docs/TODO.md)
* [Requirements](#pill-requirements)
* [Structure](#nut_and_bolt-structure-quick-reference)
* [Adding a New Host](docs/addnewhost.md)
* [Secrets Management](docs/secretsmgmt.md)
* [Initial Install Notes](docs/installnotes.md)
* [Troubleshooting](docs/TROUBLESHOOTING.md)
* [Acknowledgements](#pray-acknowledgements)
* [Guidance and Resources](#mortar_board-guidance-and-resources)

---

## :sparkles: Feature Highlights

* Flake-based multi-host, multi-user NixOS configurations
  * Core configs for hosts and users
  * Modular, optional configs for user and host-specifc needs
* Secrets management via sops-nix
* Basic NixOs and Home-Manager build automation

The roadmap of features is laid across funtionally thematic stages that can be viewed, along with short term objectives, in the [Roadmap of TODOs](docs/TODO.md). Completed features will be added here as each stage is complete.

## :pill: Requirements

* Patience
* Attention to detail
* Persistance
* More disk space

## :nut_and_bolt: Structure Quick Reference

For details about design concepts, constraints, and how structural elements interact, see [Anatomy](docs/anatomy.md).

* `flake.nix` - Entrypoint for hosts and user home configurations. Also exposes a devshell for boostrapping (`nix develop` or `nix-shell`).
* `hosts` - NixOS configurations accessible via `sudo nixos-rebuild switch --flake .#[host]`.
  * `common` - Shared configurations consumed by the machine specific ones.
    * `core` - Configurations present across all hosts. This is a hard rule! If something isn't core, it is optional.
    * `optional` - Optional configurations present across more than one host.
    * `users` - Host level user configurations present across at least one host.
  * `genoa` - stage 3
  * `ghost` - stage 4
  * `grief` - Lab - VM
  * `gooey` - stage 5
  * `gusto` - Theatre - Ausus VivoPC - 1.5GHz Celeron 1007U, 4GB RAM, onboard Intel graphics
* `home/[user]` - Home-manager configurations accessbile via `home-manager switch --flake .#[user]@[host]`.
  * `common` - Shared home-manager configurations consumed the user's machine specific ones.
    * `core` - Home-manager configuartions present for user across all machines. This is a hard rule! If something isn't core, it is optional.
    * `optional` - Optional home-manager configurations that can be added for specific machines. These can be added by category (e.g. options/media) or individually (e.g. options/media/vlc.nix) as needed.
    The home-manager core and options are defined in host-specific .nix files housed in `home/[user]`.
* `modules` - Custom modules to enable special functionality for nixos or home-manager oriented configurations.
* `overlays` - Custom modifications to upstream packages.
* `pkgs` - Custom packages meant to be shared or upstreamed.
* `scripts` - Custom scripts for automation.

## :pray: Acknowledgements

Those who have heavily influenced this strange journey into the unknown.

* [FidgetingBits](https://github.com/fidgetingbits) - You told me there was a strange door that could be opened. I'm truly grateful.
* [Misterio77](https://github.com/Misterio77) - Structure and reference.
* [Ryan Yin](https://github.com/ryan4yin/nix-config) - A treasure trove of useful documentation and ideas.
* [VimJoyer](https://github.com/vimjoyer) - Excellent videos on the highlevel concepts required to navigate NixOS.

## :mortar_board: Guidance and Resources

* [Official Nix Documentation](https://nix.dev)
  * [Best practices](https://nix.dev/guides/best-practices)
* [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) - Ryan Yin gets a second mention here. This book he's writing is fantastic.
* [Impermanence](https://github.com/nix-community/impermanence)
* Yubikey
  * <https://nixos.wiki/wiki/Yubikey>
  * [DrDuh YubiKey-Guide](https://github.com/drduh/YubiKey-Guide)

---
[Return to top](#emergentminds-nix-config)