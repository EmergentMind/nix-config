{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
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
      #
      # ========== Environment Vars ==========
      #
      env = [
        "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
        "MOZ_WEBRENDER, 1" # for firefox to run on wayland
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "QT_QPA_PLATFORM,wayland"
      ];

      #FIXME(games) this may be left over from trying stuff
      xwayland.force_zero_scaling = true;

      #
      # ========== Monitor ==========
      #
      # parse the monitor spec defined in nix-config/home/<user>/<host>.nix
      monitor = (
        map (
          m:
          "${m.name},${
            if m.enabled then
              "${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},1,transform, ${toString m.transform}"
            else
              "disable"
          }"
        ) (config.monitors)
      );

      #FIXME adapt this to work with new monitor module
      workspace = [
        "1, monitor:DP-1, default:true, persistent:true"
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

      #
      # ========== Behavior ==========
      #
      binds = {
        workspace_center_on = 1; # Whether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)
        movefocus_cycles_fullscreen = false; # If enabled, when on a fullscreen window, movefocus will cycle fullscreen, if not, it will move the focus in a direction.
      };
      input = {
        follow_mouse = 2;
        # follow_mouse options:
        # 0 - Cursor movement will not change focus.
        # 1 - Cursor movement will always change focus to the window under the cursor.
        # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
        # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
        mouse_refocus = false;
      };
      cursor.inactive_timeout = 10;
      misc = {
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        #disable_autoreload = true;
        new_window_takes_over_fullscreen = 2; # 0 - behind, 1 - takes over, 2 - unfullscreen/unmaxize
        middle_click_paste = false;
      };

      #
      # ========== Appearance ==========
      #
      #FIXME-rice colors conflict with stylix
      general = {
        gaps_in = 6;
        gaps_out = 6;
        border_size = 0;
        #col.inactive-border = "0x00000000";
        #col.active-border = "0x0000000";
        resize_on_border = true;
        hover_icon_on_border = true;
        allow_tearing = true; # used to reduce latency and/or jitter in games
      };
      decoration = {
        active_opacity = 1.0;
        inactive_opacity = 0.85;
        fullscreen_opacity = 1.0;
        rounding = 10;
        blur = {
          enabled = false;
          size = 5;
          passes = 3;
          new_optimizations = true;
          popups = true;
        };
        drop_shadow = true;
        shadow_range = 12;
        shadow_offset = "3 3";
        #"col.shadow" = "0x44000000";
        #        "col.shadow_inactive" = "0x66000000";
      };
      # group = {
      #groupbar = {
      #          };
      #};

      #
      # ========== Auto Launch ==========
      #
      # exec-once = ''${startupScript}/path'';
      # To determine path, run `which foo`
      exec-once = [
        ''${pkgs.waypaper}/bin/waypaper''
        ''[workspace 0 silent]${pkgs.copyq}/bin/copyq''
        ''[workspace 9 silent]${pkgs.signal-desktop}/bin/signal-desktop''
        ''[workspace 9 silent]${pkgs.yubioath-flutter}/bin/yubioath-flutter''
        ''[workspace 0 silent]${pkgs.spotify}/bin/spotify''
      ];
      #
      # ========== Layer Rules ==========
      #
      layer = [
        #"blur, rofi"
        #"ignorezero, rofi"
        #"ignorezero, logout_dialog"

      ];
      #
      # ========== Window Rules ==========
      #
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
          #FIXME these aren't working for some reason; higher priority so switched to manual entry for now
          flameshot = "class:^(flameshot)$, title:^(flameshot)$";
          scratch = "workspace:^(special:special)$";
          #steam = "title:^()$ class:^([Ss]team)$";
          steam = "title:^(*)$ class:^([Ss]team)$";
          steamFloat = "title:^((?![Ss]team)*)$, class:^([Ss]team)$";
          steamGame = "class:^([Ss]team_app_*)$";
        in
        [
          "float, class:^(galculator)$"
          "float, class:^(waypaper)$"

          #
          # ========== Always opaque ==========
          #
          #FIXME This isn't working... probably have the wrong option
          "opaque, class:^([Gg]imp)$"
          "opaque, class:^([Ff]lameshot)$"
          "opaque, class:^([Ii]nkscape)$"
          "opaque, class:^([Bb]lender)$"
          "opaque, class:^([Oo][Bb][Ss])$"
          "opaque, class:^(([Ss]team))$"
          "opaque, class:^(([Ss]team_app_*)$"

          # Remove transparancy from video
          "opaque, title:^(Netflix)(.*)$"
          "opaque, title:^(.*YouTube.*)$"
          "opaque, title:^(Picture-in-Picture)$"
          #
          # ========== Scratch rules ==========
          #
          #"size 80% 85%, workspace:^(special:special)$"
          #"center, workspace:^(special:special)$"

          #
          # ========== Steam rules ==========
          #
          "stayfocused, title:^()$,class:^(([Ss]team))$"
          "minsize 1 1, title:^()$,class:^(([Ss]team))$"
          #"workspace 7, class:^(([Ss]team_app_*))$"
          #"monitor 0, class:^(([Ss]team_app_*))$"
          "immediate, class:^(([Ss]team_app_*))$"
          #"float, ${steamFloat}"
          #"stayfocused, ${steam}"
          #"minsize 1 1, ${steam}"
          #"workspace 7, ${steamGame}"
          #"monitor 0, ${steamGame}"
          #"immediate, ${steamGame}"

          #
          # ========== Fameshot rules ==========
          #
          # flameshot currently doesn't have great wayland support so needs some tweaks
          #"rounding 0, class:^([Ff]lameshot)$"
          #"noborder, class:^([Ff]lameshot)$"
          #"float, class:^([Ff]lameshot)$"
          #"move 0 0, class:^([Ff]lameshot)$"
          #"suppressevent fullscreen, class:^([Ff]lameshot)$"
          # "monitor:DP-1, ${flameshot}"

          #
          # ========== Workspace Assignments ==========
          #
          "workspace 8, class:^(virt-manager)$"
          "workspace 8, class:^(obsidian)$"
          "workspace 9, class:^(brave-browser)$"
          "workspace 9, class:^(signal)$"
          "workspace 9, class:^(org.telegram.desktop)$"
          "workspace 9, class:^(discord)$"
          "workspace 9, class:^(yubioath-flutter)$"
          "workspace 0, class:^(spotify)$"
        ];

      # load at the end of the hyperland set
      # extraConfig = '''';
    };
  };
}
