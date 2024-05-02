{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    nixosConfigurations = {
      guppy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = minimalSpecialArgs;
        modules = [
          disko.nixosModules.disko
          ../hosts/common/disks/std-disk-config.nix
          ./configuration.nix
          ../hosts/guppy/hardware-configuration.nix
        ];
      };
    };
  };
}
