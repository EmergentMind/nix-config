{ pkgs, lib, ... }:
{
  imports = [
    # custom key binds
    ./binds.nix
  ];

  # NOTE: xdg portal package is currently set in /hosts/common/optional/hyprland.nix

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ]; # fix for https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
      #   # TODO: experiment with whether this is required.
      #   # Same as default, but stop the graphical session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    # plugins = [];

    settings = {
      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      # https://wiki.hyprland.org/Configuring/Monitors/
      #            ------
      #           | DP-3 |
      #            ------
      #  ------   -----   ------
      # | DP-2 | | DP-1  | HDMI-A-1 |
      #  ------   -----   ------
      monitor = [
        "DP-1, 2560x1440@240, 0x0, 1"
        "DP-2, 2560x2880@60, -2560x840, 1"
        "DP-3, 1920x1080@60, 0x-1080, 1, transform, 2"
        "HDMI-A-1, 2560x2880@60, 2560x840, 1"
      ];

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
      #     col.inactive-border = "0x00000000";
      #     col.active-border = over18?dest=https%3A%2F%2Fold.reddit.com%2Fr%2Fnsfw0.75;
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
      #  misc = {
      #  disable_hyprland_logo = true;
      #  animate_manual_resizes = true;
      #  animate_mouse_windowdragging = true;
      #  disable_autoreload = true;
      #  new_window_takes_over_fullscreen = 1;
      #  initial_workspace_tracking = 0;
      #};

      # exec-once = ''${startupScript}/path'';
    };

    # load at the end of the hyperland set
    # extraConfig = ''    '';
  };

  # TODO: move below into individual .nix files with their own configs
  home.packages = builtins.attrValues {
    inherit (pkgs)

      # Wallpaper daemon
      # NOTE: most of these don't exist in home-manager so maybe just go with one that is
      hyprpaper
      #   swaybg
      #   wpaperd
      #   mpvpaper
      # swww # vimjoyer recoomended
      #   nitrogen

      # App launcher
      rofi-wayland
      ;
  };
}
