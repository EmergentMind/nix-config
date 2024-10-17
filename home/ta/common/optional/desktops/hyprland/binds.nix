{
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    bindm = [
      # alt + leftlclick
      "ALT,mouse:272,movewindow"
      # alt + rightclick
      "ALT,mouse:273,resizewindow"
    ];

    bind =
      let
        workspaces = [
          "0"
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "F1"
          "F2"
          "F3"
          "F4"
          "F5"
          "F6"
          "F7"
          "F8"
          "F9"
          "F10"
          "F11"
          "F12"
        ];
        # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
        directions = rec {
          left = "l";
          right = "r";
          up = "u";
          down = "d";
          h = left;
          l = right;
          k = up;
          j = down;
        };
        pactl = lib.getExe' pkgs.pulseaudio "pactl"; # installed via /hosts/common/optional/audio.nix
      in
      #playerctl = lib.getExe pkgs.playerctl; # installed via /home/common/optional/desktops/playerctl.nix
      #swaylock = "lib.getExe pkgs.swaylock;
      #makoctl = "${config.services.mako.package}/bin/makoctl";
      #gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
      #notify-send = "${pkgs.libnotify}/bin/notify-send";
      #gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
      #xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
      #defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";
      #terminal = config.home.sessionVariables.TERM;
      #browser = defaultApp "x-scheme-handler/https";

      lib.flatten [
        #
        # ========== Program Launch ==========
        #
        "ALT,Return,exec,kitty"
        "CTRL_ALT,v,exec,kitty nvim"
        "SUPER,space,exec,rofi -show run"
        "SUPER_SHIFT,space,exec,rofi -show drun"
        "SUPER,s,exec,rofi -show ssh"
        "ALT,tab,exec,rofi -show window"
        "CTRL_ALT,f,exec,thunar"

        #
        # ========== Screenshotting ==========
        #
        # TODO check on status of flameshot and multimonitor wayland. as of Oct 2024, it's a clusterfuck
        # so resorting to grimblast in the meantime
        #"CTRL_ALT,8,exec,flameshot gui"
        "CTRL_ALT,8,exec,grimblast --notify --freeze copy area"
        "CTRL_ALT,p,exec,grimblast --notify --freeze copy area"
        ",Print,exec,grimblast --notify --freeze copy area"

        #
        # ========== Basic Binds ==========
        #
        #reload the configuration file
        "SHIFTALT,r,exec,hyprctl reload"

        "SHIFTALT,q,killactive"
        #"SHIFTALT,e,exit"

        "ALT,s,togglesplit"
        "ALT,f,fullscreen,0" # 0 - fullscreen (takes your entire screen), 1 - maximize (keeps gaps and bar(s))
        #FIXME play around with fullscreenstate to get a setting that works with maximizing sec cams in window
        #",,fullscreenstate,0"
        "SHIFTALT,space,togglefloating"
        "SHIFTALT, p, pin" # pins a floating window (i.e. show it on all workspaces)

        #FIXME this works differently in hyprland
        #"SHIFALT, r, resizeactive"

        #"SHIFTALT,minus,splitratio,-0.25"
        #"SHIFTALT,equal,splitratio,0.25"

        "ALT,g,togglegroup"
        "ALT,t,lockactivegroup,toggle"
        "ALT,apostrophe,changegroupactive,f"
        "SHIFTALT,apostrophe,changegroupactive,b"

        "ALT,y, togglespecialworkspace"
        "SHIFTALT,y,movetoworkspace,special"

        #
        # ========== Media Controls ==========
        #
        # Output
        ", XF86AudioMute, exec, ${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioRaiseVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +1%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -1%"
        # Input
        ", XF86AudioMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioRaiseVolume, exec, ${pactl} set-source-volume @DEFAULT_SOURCE@ +1%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-source-volume @DEFAULT_SOURCE@ -1%"
        # Player
        #FIXME For some reason these key pressings aren't firing from Moonlander. Nothing shows when running wev
        ", XF86AudioPlay, exec, 'playerctl --ignore-player=firefox,chromium,brave play-pause'"
        ", XF86AudioNext, exec, 'playerctl --ignore-player=firefox,chromium,brave next'"
        ", XF86AudioPrev, exec, 'playerctl --ignore-player=firefox,chromium,brave previous'"

        #
        # ========== Workspace ==========
        #
        # Change workspace
        (map (n: "ALT,${n},workspace,name:${n}") workspaces)

        # Move window to workspace
        (map (n: "SHIFTALT,${n},movetoworkspace,name:${n},follow") workspaces)

        # Move focus
        (lib.mapAttrsToList (key: direction: "ALT,${key},movefocus,${direction}") directions)

        # Swap windows
        #   (lib.mapAttrsToList
        #      (key: direction: "SHIFTALT,${key},swapwindow,${direction}") directions)

        # Move windows
        (lib.mapAttrsToList (key: direction: "SHIFTALT,${key},movewindow,${direction}") directions)

        # Move workspace to other monitor
        (lib.mapAttrsToList (
          key: direction: "CTRLSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        ) directions)
        # Move monitor focus
        #(lib.mapAttrsToList
        #      (key: direction: "ALTALT,${key},focusmonitor,${direction}") directions)
      ];
  };
}
