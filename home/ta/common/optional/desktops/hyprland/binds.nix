{
  lib,
  pkgs,
  config,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {

    input = {

      follow_mouse = 2;
      # follow_mouse options:
      # 0 - Cursor movement will not change focus.
      # 1 - Cursor movement will always change focus to the window under the cursor.
      # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
      # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
      mouse_refocus = false;
    };

    bindm = [
      "ALT,mouse:272,movewindow"
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
        #swaylock = "${config.programs.swaylock.package}/bin/swaylock";
        pactl = "${pkgs.pulseaudio}/bin/pactl"; # installed via /hosts/common/optional/audio.nix
        playerctl = "${pkgs.playerctl}/bin/playerctl"; # installed via /home/common/optional/desktops/playerctl.nix
      in
      #makoctl = "${config.services.mako.package}/bin/makoctl";
      #pass-wofi = "${pkgs.pass-wofi.override {
      #pass = config.programs.password-store.package;
      #}}/bin/pass-wofi";
      #grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
      #tly = "${pkgs.tly}/bin/tly";
      #gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
      #notify-send = "${pkgs.libnotify}/bin/notify-send";
      #gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
      #xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
      #defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";
      #terminal = config.home.sessionVariables.TERM;
      #browser = defaultApp "x-scheme-handler/https";
      #editor = defaultApp "text/plain";

      lib.flatten [
        #################### Program Launch ####################
        "ALT,Return,exec,kitty"
        "CTRL_ALT,v,exec,kitty nvim"
        "SUPER,space,exec,rofi -show run"
        "ALT,tab,exec,rofi -show window"
        "CTRL_ALT,f,exec,thunar"
        #FIXME: this isn't working... may need a rule for window handling in hyprland
        "CTRL_ALT,8,exec,flameshot gui"

        #################### Basic Bindings ####################
        #reload the configuration file
        "SHIFTALT,r,exec,hyprctl reload"

        "SHIFTALT,q,killactive"
        #"SHIFTALT,e,exit"

        "ALT,s,togglesplit"
        "ALT,f,fullscreen,0" # 0 - fullscreen (takes your entire screen), 1 - maximize (keeps gaps and bar(s))
        #FIXME: play around with fullscreenstate to get a setting that works with maximizing sec cams in window
        #",,fullscreenstate,0"
        "SHIFTALT,space,togglefloating"
        "SHIFTALT, p, pin" # pins a floating window (i.e. show it on all workspaces)

        "SHIFALT, r, resizeactive"

        #        "SHIFTALT,minus,splitratio,-0.25"
        #        "SHIFTALT,equal,splitratio,0.25"

        "ALT,g,togglegroup"
        "ALT,t,lockactivegroup,toggle"
        "ALT,apostrophe,changegroupactive,f"
        "SHIFTALT,apostrophe,changegroupactive,b"

        "ALT,-,togglespecialworkspace"
        "SHIFTALT,-,movetoworkspacesilent,special"

        #################### Media Controls ####################
        # Output
        ", XF86AudioMute, exec, ${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioRaiseVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +1%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -1%"
        # Input
        ", XF86AudioMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioRaiseVolume, exec, ${pactl} set-source-volume @DEFAULT_SOURCE@ +1%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-source-volume @DEFAULT_SOURCE@ -1%"
        # Player controls
        ", XF86AudioPlay, exec, '${playerctl} --ignore-player=firefox,chromium,brave play-pause'"
        ", XF86AudioNext, exec, '${playerctl} --ignore-player=firefox,chromium,brave next'"
        ", XF86AudioPrev, exec, '${playerctl} --ignore-player=firefox,chromium,brave previous'"

        # Change workspace
        (map (n: "ALT,${n},workspace,name:${n}") workspaces)

        # Move window to workspace
        (map (n: "SHIFTALT,${n},movetoworkspacesilent,name:${n}") workspaces)

        # Move focus
        (lib.mapAttrsToList (key: direction: "ALT,${key},movefocus,${direction}") directions)

        # Swap windows
        #   (lib.mapAttrsToList
        #      (key: direction: "SHIFTALT,${key},swapwindow,${direction}") directions)

        # Move windows
        (lib.mapAttrsToList (key: direction: "SHIFTALT,${key},movewindoworgroup,${direction}") directions)

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
