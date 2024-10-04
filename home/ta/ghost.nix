{ configVars, ... }:
{
  imports = [
    #################### Required Configs ####################
    common/core # required

    #################### Host-specific Optional Configs ####################
    common/optional/browsers
    common/optional/desktops # default is hyprland
    common/optional/comms
    common/optional/helper-scripts
    common/optional/media
    common/optional/tools

    common/optional/xdg.nix # file associations
    common/optional/sops.nix
  ];

  services.yubikey-touch-detector.enable = true;

  home = {
    username = configVars.username;
    homeDirectory = "/home/${configVars.username}";
  };

}
