{ inputs, lib, ... }:
{
  nix = {
    settings = {
      substituters = [
        "https://hyprland.cachix.org" # https://wiki.hyprland.org/Nix/Cachix/
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # https://wiki.hyprland.org/Nix/Cachix/
      ];
      trusted-users = [ "root" "@wheel" ];

      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
      system-features = [ "kvm" "big-parallel" "nixos-test" ];
      flake-registry = ""; # Disable global flake registry   This is a hold-over setting from Misterio77. Not sure significance but likely to do with nix.registry entry below.
    };

    # Add each flake input as a registry to make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];

    # Garbage Collection
    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "14m";
      # Keep the last 5 generations
      options = "--delete-older-than +5";
    };

 };
}
