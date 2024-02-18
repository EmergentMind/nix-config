{ inputs, outputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./locale.nix          # loclalization settings
    ./nix.nix             # nix settings and garbage collection
    ./sops.nix            # secrets management
    ./zsh.nix             # load a basic shell just incase we need it without home-manager

    ./services/auto-upgrade.nix # auto-upgrade service

  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    # you can add global overlays here
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  hardware.enableRedistributableFirmware = true;
}
