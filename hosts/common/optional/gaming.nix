{ pkgs, configVars, ... }:
{
  hardware.xone.enable = true; # support for the xbox controller USB dongle
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true; # Add cap_sys_nice capability to the GameScope binary so that it may renice itself.
    };
    # Steam must be installed at the system level
    # https://discourse.nixos.org/t/ssl-peer-certificate-or-ssh-remote-key-was-not-ok-when-launching-steam/40274
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
      settings = {
        #see gamemoded man page for settings info
        general = {
          softrealtime = "on";
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };
  environment.variables = {
    STEAM_FORCE_DESKTOPUI_SCALING = configVars.scaling;
  };

  #TODO
  # path-of-building
  # awakened-poe-trade
}
