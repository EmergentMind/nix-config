{ inputs, configVars, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence

    #################### Required Configs ####################
    common/core #required

    #################### Host-specific Optional Configs ####################
    common/optional/sops.nix
    common/optional/helper-scripts

    common/optional/desktops
  ];

  services.yubikey-touch-detector.enable = true;

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";
  };
}
