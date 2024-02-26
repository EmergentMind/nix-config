# Anatomy

[README](../README.md) > Anatomy

## Structural Concept
The following diagram depicts the conceptual anatomy of my nix-config. It is not an accurate representation of the current state but will be updated over time to represent additional elements and details as the config evolves.
![Anatomy v1](diagrams/anatomy_v1.png)

## Details
For details about the design concepts, constraints, and how structural elements interact, see the article and/or Youtube video [Anatomy of a NixOS Config](https://unmovedcentre.com/technology/2024/02/24/anatomy-of-a-nixos-config.html) available on my website.

## Fugly visual of the current state as of Feb 25, 2024

The following diagram is a more accurate, albeit less visually appealing representation of the current state, written in mermaid syntax.

```mermaid

flowchart LR

  subgraph flakeurls
    stable ~~~ sops-nix
    unstable ~~~ home-manager
    hardware  ~~~ nixvim
  end

  subgraph flake.nix
    inputs ~~~ outputs
  end

  subgraph ./modules
    ./modules/nixos
    ./modules/home-manager
  end

  subgraph ./hosts
    ./hosts/grief.nix
    ./hosts/gusto.nix
    subgraph ./hosts/common

      subgraph ./hosts/common/core
      services
      locale
      nix
      sops
      zsh
      end 

      subgraph ./hosts/common/optional
      optional-services
      yubikey
      hyprland
      msmtp
      pipewire
      smbclient
      vlc
      xfce
      end

      subgraph ./hosts/common/users
      ta
      media
      end

    end
  end

  subgraph ./home
    subgraph ./home/ta
      ./home/ta/grief.nix
      ./home/ta/gusto.nix
      subgraph ./home/ta/common
        subgraph ./home/ta/common/core
          bash
          bat
          direnv
          fonts
          git
          kitty
          nvim
          screen
          ssh
          zoxide
          zsh
        end
        subgraph ./home/ta/common/optional
          browsers/brave
          desktops/gtk
          desktops/hyprland
          sops-ta
          helper-scripts
        end
      end
    end
    subgraph ./home/media
      ./home/media/gusto.nix
      subgraph ./home/media/common
        subgraph ./home/media/common/core
          brave
          gtk
        end
      end
    end
  end


  flakeurls --> inputs
  outputs --> ./modules/nixos
  outputs --> ./modules/home-manager 
  outputs --> ./overlays
  outputs --> ./pkgs
  outputs --> ./shell.nix
  outputs --> formatter
  outputs --> ./hosts/ghost.nix
  outputs --> ./hosts/gusto.nix
  outputs --> ./home/ta/grief.nix
  outputs --> ./home/ta/gusto.nix
  outputs --> ./home/media/gusto.nix

  ./hosts/grief.nix --> ./hosts/common/core
  ./hosts/grief.nix -.-> ./hosts/common/optional

  ./hosts/gusto.nix --> ta
  ./hosts/gusto.nix -.-> media
  ./hosts/gusto.nix --> ./hosts/common/core
  ./hosts/gusto.nix -.-> xfce
  ./hosts/gusto.nix -.-> pipewire
  ./hosts/gusto.nix -.-> vlc

  ./home/ta/grief.nix --> ./home/ta/common/core
  ./home/ta/grief.nix --> ./home/ta/common/optional
  ./home/ta/gusto.nix --> ./home/ta/common/core
  ./home/ta/gusto.nix -.-> sops-ta
  ./home/ta/gusto.nix -.-> helper-scripts
  ./home/ta/gusto.nix -.-> browsers/brave
  ./home/ta/gusto.nix -.-> desktops/gtk

  ./home/media/gusto.nix --> ./home/media/common/core

```

---
[Return to top](#anatomy)

[README](../README.md) > Anatomy
