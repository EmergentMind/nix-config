{ pkgs, ... }:
{
  # most gaming related config options are in home/ta/common/optional/gaming/

  hardware.xone.enable = true; # xbox controller

  # to run steam games in game mode, add the following to the game's properties from within steam
  # gamemoderun %command%
  programs.gamemode = {
    enable = true;
    settings = {
      #see gamemode man page for settings info
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
}
