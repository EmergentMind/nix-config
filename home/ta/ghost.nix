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
    common/optional/gaming
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

  # Configure monitors for the host here. This uses the nix-config/modules/home-manager/montiors.nix module which defaults to enabled.
  # Your nix-config/home-manger/<user>/common/optional/desktops/foo.nix WM config should parse and apply these values to it's monitor settings
  # If on hyprland, use `hyprctl monitors` to get monitor info.
  # https://wiki.hyprland.org/Configuring/Monitors/
  #           ------
  #          | DP-3 |
  #           ------
  #  ------   ------    ------
  # | DP-2 | | DP-1 | | HDMI-A-1 |
  #  ------   ------    ------
  monitors = [
    {
      name = "DP-1";
      width = 2560;
      height = 1440;
      refreshRate = 240;
      primary = true;
    }
    {
      name = "DP-2";
      width = 2560;
      height = 2880;
      refreshRate = 60;
      x = -2560;
      workspace = "8";
    }
    {
      name = "DP-3";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      y = -1080;
      transform = 2;
      workspace = "9";
    }
    {
      name = "HDMI-A-1";
      width = 2560;
      height = 2880;
      refreshRate = 60;
      x = 2560;
      workspace = "0";
    }
  ];
}
