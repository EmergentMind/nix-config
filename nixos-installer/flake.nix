{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Declarative partitioning and formatting
    disko.url = "github:nix-community/disko";
    # Image and iso generator
    nixos-generators.url = "github:nix-community/nixos-generators";
    };
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
    minimalSpecialArgas = {
      inherit inputs outputs configLib;
      configVars = minimalConfigVars;
    };
  in
  {
    nixosConfigurations = {
      #################### NixOS Installer Images ####################
      #
      # Available through `nix build .#nixosConfigurations.[targetConfig].config.system.build.isoImage`
      # Generated images will be output to ./results
      #
      iso = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ../hosts/iso
        ];
      };

      #################### Target Hosts ####################
      #
      # Installer test lab
      #
      guppy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = minimalSpecialArgs;
        modules = [
          disko.nixosModules.disko
          ../hosts/common/disks/std-disk-config.nix
          ./configuration.nix
          ../hosts/common/guppy/hardware-configuration.nix
        ];
      };
    };
  };
}
