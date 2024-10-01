{
  pkgs,
  lib,
  ...
}:
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
        "QT_QPA_PLATFORM,wayland"
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
        "DP-2, 2560x2880@60, -2560x0, 1"
        "DP-3, 1920x1080@60, 0x-1080, 1, transform, 2"
        "HDMI-A-1, 2560x2880@60, 2560x0, 1"
      ];

      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1, default:true"
        "3, monitor:DP-1, default:true"
        "4, monitor:DP-1, default:true"
        "5, monitor:DP-1, default:true"
        "6, monitor:DP-1, default:true"
        "7, monitor:DP-1, default:true"
        "8, monitor:DP-2, default:true, persistent:true"
        "9, monitor:DP-3, default:true, persistent:true"
        "0, monitor:HDMI-A-1, default:true, persistent:true"
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
      misc = {
        #  disable_hyprland_logo = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        #  disable_autoreload = true;
        new_window_takes_over_fullscreen = 2; # 0 - behind, 1 - takes over, 2 - unfullscreen/unmaxize [0/1/2]
        middle_click_paste = false;
      };

      # Autostart applications
      # exec-once = ''${startupScript}/path'';
      exec-once = [
        ''${pkgs.copyq}/bin/copyq''
        ''${pkgs.signal-desktop}/bin/signal''
        ''${pkgs.yubioath-flutter}/bin/yubioath-flutter''
        ''${pkgs.spotify}/bin/spotify''
      ];
      windowrule = [
        # Dialogs
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(Accounts)(.*)$"
      ];

      windowrulev2 =
        let
          flameshot = "class:^(flameshot)$,title:^(flameshot)$";
          scratch = "class:^(scratch_term)$";
          steam = "title:^()$,class:^([Ss]team)$";
          steamFloat = "title:^((?![Ss]team).*)$,class:^([Ss]team)$";
          steamGame = "class:^([Ss]team_app_.*)$";
        in
        [
          "float, class:^(galculator)$"
          "float, class:^(waypaper)$"

          # flameshot currently doesn't have great wayland support so needs some tweaks
          #          "monitor DP-1, ${flameshot}"
          "rounding 0, ${flameshot}"
          "noborder, ${flameshot}"
          "float, ${flameshot}"
          "move 0 0, ${flameshot}"
          "suppressevent fullscreen, ${flameshot}"

          "float, ${scratch}"
          "size 80% 85%, ${scratch}"
          "workspace special:scratch_term, ${scratch}"
          "center, ${scratch}"

          "float, ${steamFloat}"
          "stayfocused, ${steam}"
          "minsize 1 1, ${steam}"
          "workspace 7, ${steamGame}"
          "immediate, ${steamGame}"

          # WORKSPACE ASSIGNMENTS
          "workspace 8, class:^(virt-manager)"
          "workspace 8, class:^(obsidian)"
          "workspace 9, class:^(signal-desktop)"
          "workspace 9, class:^(yubioath-flutter)"
          "workspace 0, class:^(spotify)"
        ];

      # load at the end of the hyperland set
      # extraConfig = '''';
    };
  };
}
