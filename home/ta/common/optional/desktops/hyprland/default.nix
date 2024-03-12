{ pkgs, lib, ... }: {
  imports = [
    # custom key binds
    ./binds.nix
  ];

  # NOTE: xdg portal package is currently set in /hosts/common/optional/hyprland.nix

  wayland.windowManager.hyprland = {
    enable = true;
    # systemd = {
    #   enable = true;
    #   # TODO: experiment with whether this is required.
    #   # Same as default, but stop the graphical session too
    #   extraCommands = lib.mkBefore [
    #     "systemctl --user stop graphical-session.target"
    #     "systemctl --user start hyprland-session.target"
    #   ];
    # };

    # plugins = [];

    settings = {
      env = [
        "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
        "MOZ_WEBRENDER, 1" # for firefox to run on wayland
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        # "QT_QPA_PLATFORM,wayland"
      ];

      #   general = {
      #     gaps_in = 8;
      #     gaps_out = 5;
      #     border_size = 3;
      #     cursor_inactive_timeout = 4;
      #   };
      #
      #   input = {
      #   kb_layout = "us";
      #     # mouse = {
      #     #   acceleration = 1.0;
      #     #   naturalScroll = true;
      #     # };
      #   };
      #
      #   decoration = {
      #     active_opacity = 0.94;
      #     inactive_opacity = 0.75;
      #     fullscreen_opacity = 1.0;
      #     # rounding = 7;
      #     blur = {
      #     enabled = false;
      #     size = 5;
      #     passes = 3;
      #     new_optimizations = true;
      #     ignore_opacity = true;
      #   };
      #   drop_shadow = false;
      #   shadow_range = 12;
      #   shadow_offset = "3 3";
      #   "col.shadow" = "0x44000000";
      #   "col.shadow_inactive" = "0x66000000";
      # };

      # exec-once = ''${startupScript}/path'';
    };

    # load at the end of the hyperland set
    # extraConfig = ''    '';
  };

  # # TODO: move below into individual .nix files with their own configs
  # home.packages = builtins.attrValues {
  #   inherit (pkgs)
  #   nm-applet --indicator &  # notification manager applet.
  #   bar
  #   waybar  # closest thing to polybar available
  #   where is polybar? not supported yet: https://github.com/polybar/polybar/issues/414
  #   eww # alternative - complex at first but can do cool shit apparently
  #
  #   # Wallpaper daemon
  #   hyprpaper
  #   swaybg
  #   wpaperd
  #   mpvpaper
  #   swww # vimjoyer recoomended
  #   nitrogen
  #
  #   # app launcher
  #   rofi-wayland;
  #   wofi # gtk rofi
  # };
}
