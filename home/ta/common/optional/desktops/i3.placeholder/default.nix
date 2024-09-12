# This is mainly here for quick reference of what my i3 settings were before moving to hyprland.

{
  pkgs,
  config,
  lib,
  configLib,
  ...
}:
let
  cfg = config.modules.desktop.i3;
in
{
  imports = configLib.scanPaths ./.;

  options.modules.desktop.i3 = {
    enable = lib.mkEnableOption "i3 window manager";
  };

  config = lib.mkIf cfg.enable {
    # NOTE:
    # We have to enable hyprland/i3's systemd user service in home-manager,
    # so that gammastep/wallpaper-switcher's user service can be start correctly!
    # they are all depending on hyprland/i3's user graphical-session
    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        config = lib.mkForce null; # ignores all home-manager's default i3 config
        extraConfig = builtins.readFile ./i3-config;
      };
      # Path, relative to HOME, where Home Manager should write the X session script.
      # and NixOS will use it to start xorg session when system boot up
      scriptPath = ".xsession";
    };
  };
}

