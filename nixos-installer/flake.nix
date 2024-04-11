{
  description = "minimal NixOS installer flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # image and iso generator
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }@inputs: {
    nixosConfigurations = {
      #################### NixOS Installer Images ####################
      #
      # Available through `nix build .#nixosConfigurations.[targetConfig].config.system.build.isoImage`
      #
      # Generated images will be output to ./results
      iso = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ./customISO.nix
        ];
      };

      #################### Target Hosts ####################
      #
      # Installer test lab
      #
      guppy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./std-disk-config.nix
        ];
      };
    };
  };
}
