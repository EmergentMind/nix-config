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
      customISO = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./customISO.nix ];
      };
      #vboxImage = nixos-generators.nixosGenerate {
      #format = "virtualbox";
      #modules = [ ./iso.nix];
      #specialArgs = { inherit inputs outputs; };
      #};


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
