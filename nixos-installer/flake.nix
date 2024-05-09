{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs:
  let
    inherit (self) outputs;
    inherit (nixpkgs) lib;
    configVars = import ../vars { inherit inputs lib; };
    configLib = import ../lib { inherit lib; };
    specialArgs = { inherit inputs configVars configLib; };
    minimalConfigVars = lib.recursiveUpdate configVars {
      isMinimal = true;
    };
    minimalSpecialArgs = {
      inherit inputs outputs configLib;
      configVars = minimalConfigVars;
    };
  in
  {
    #################### Minimal Configurations ####################
    #
    # Minimal configuration for bootstrapping hosts
    nixosConfigurations = {
      guppy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = minimalSpecialArgs;
        modules = [
          disko.nixosModules.disko
          ../hosts/common/disks/std-disk-config.nix
          ./minimal-configuration.nix
          ../hosts/guppy/hardware-configuration.nix
        ];
      };

      # Custom ISO
      #
      # `just iso` - from nix-config directory to generate the iso standalone
      # 'just iso-install <drive>` - from nix-config directory to generate and copy directly to USB drive
      # `nix build ./nixos-installer#nixosConfigurations.iso.config.system.build.isoImage` - from nix-config directory to generate the iso manually
      #
      # Generated images will be output to the ~/nix-config/results directory unless drive is specified
      iso = nixpkgs.lib.nixosSystem {
        specialArgs = minimalSpecialArgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ./iso
        ];
      };
    };
  };
}
