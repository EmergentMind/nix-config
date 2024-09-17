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
      env = [
        "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
        "MOZ_WEBRENDER, 1" # for firefox to run on wayland
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        # "QT_QPA_PLATFORM,wayland"
      ];

      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      # https://wiki.hyprland.org/Configuring/Monitors/
      #           ------
      #          | DP-3 |
      #           ------
      #  ------   ------    ------
      # | DP-2 | | DP-1 | | HDMI-A-1 |
      #  ------   ------    ------
      monitor = [
        "DP-1, 2560x1440@240, 0x0, 1"
        "DP-2, 2560x2880@60, -2560x840, 1"
        "DP-3, 1920x1080@60, 0x-1080, 1, transform, 2"
        "HDMI-A-1, 2560x2880@60, 2560x840, 1"
      ];

      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1, default:true"
        "3, monitor:DP-1, default:true"
        "4, monitor:DP-1, default:true"
        "5, monitor:DP-1, default:true"
        "6, monitor:DP-1, default:true"
        "7, monitor:DP-1, default:true"
        "8, monitor:DP-2, default:true"
        "9, monitor:DP-3, default:true"
        "0, monitor:HDMI-A-1, default:true"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 6;
        border_size = 3;
        resize_on_border = true;
        hover_icon_on_border = true;
        #cursor_inactive_timeout = 4;
      };
      #      decoration = {
      #     col.inactive-border = "0x00000000";
      #     col.active-border = "0x0000000";
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
      #};
      # group = {

      #groupbar = {
      #          };
      #};
      #  misc = {
      #  disable_hyprland_logo = true;
      #  animate_manual_resizes = true;
      #  animate_mouse_windowdragging = true;
      #  disable_autoreload = true;
      #  new_window_takes_over_fullscreen = 1;
      #  initial_workspace_tracking = 0;
      #};

      # exec-once = ''${startupScript}/path'';
      windowrulev2 =
        let
          steam = "title:^()$,class:^(steam)$";
          steamGame = "class:^(steam_app_[0-9]*)$";
        in
        [
          "stayfocused, ${steam}"
          "minsize 1 1, ${steam}"

          "immediate, ${steamGame}"
        ];

      # load at the end of the hyperland set
      # extraConfig = ''    '';
    };
  };
}
