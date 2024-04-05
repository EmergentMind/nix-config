{ pkgs, lib, config, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  #TODO: move this to flake
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      rsync;
  };

  #nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
