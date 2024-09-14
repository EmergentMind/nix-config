{ lib, config, ... }: {
  wayland.windowManager.hyprland.settings = {
    bindm = [ "ALT,mouse:272,movewindow" "ALT,mouse:273,resizewindow" ];

    bind = let
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
      #playerctl = "${config.services.playerctld.package}/bin/playerctl";
      #playerctld = "${config.services.playerctld.package}/bin/playerctld";
      #makoctl = "${config.services.mako.package}/bin/makoctl";
      #pass-wofi = "${pkgs.pass-wofi.override {
      #pass = config.programs.password-store.package;
      #}}/bin/pass-wofi";
      #grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
      #pactl = "${pkgs.pulseaudio}/bin/pactl";
      #tly = "${pkgs.tly}/bin/tly";
      #gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
      #notify-send = "${pkgs.libnotify}/bin/notify-send";
      #gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
      #xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
      #defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";
      #terminal = config.home.sessionVariables.TERM;
      #browser = defaultApp "x-scheme-handler/https";
      #editor = defaultApp "text/plain";
    in [
      #################### Program Launch ####################
      "ALT,Return,exec,kitty"
      "SUPER,space,exec,rofi -show run"

      #################### Basic Bindings ####################
      "SHIFTALT,q,killactive"
      "ALTSHIFT,e,exit"

      "ALT,s,togglesplit"
      "ALT,f,fullscreen,1"
      "ALTSHIFT,f,fullscreen,0"
      "ALTSHIFT,space,togglefloating"
      # "ALT, foo, pin"

      "ALT,minus,splitratio,-0.25"
      "ALTSHIFT,minus,splitratio,-0.3333333"

      "ALT,equal,splitratio,0.25"
      "ALTSHIFT,equal,splitratio,0.3333333"

      "ALT,g,togglegroup"
      "ALT,t,lockactivegroup,toggle"
      "ALT,apostrophe,changegroupactive,f"
      "ALTSHIFT,apostrophe,changegroupactive,b"

      "ALT,u,togglespecialworkspace"
      "ALTSHIFT,u,movetoworkspacesilent,special"
    ] ++
    # Change workspace
    (map (n: "ALT,${n},workspace,name:${n}") workspaces) ++
    # Move window to workspace
    (map (n: "SHIFTALT,${n},movetoworkspacesilent,name:${n}") workspaces) ++
    # Move focus
    (lib.mapAttrsToList (key: direction: "ALT,${key},movefocus,${direction}")
      directions) ++
    # Swap windows
    #   (lib.mapAttrsToList
    #      (key: direction: "ALTSHIFT,${key},swapwindow,${direction}") directions)
    #    ++
    # Move windows
    (lib.mapAttrsToList
      (key: direction: "SHIFTALT,${key},movewindoworgroup,${direction}")
      directions);
    # Move monitor focus
    #(lib.mapAttrsToList
    #      (key: direction: "ALTALT,${key},focusmonitor,${direction}") directions)
    #    ++
    # Move workspace to other monitor
    #    (lib.mapAttrsToList (key: direction:
    #      "SHIFTALT,${key},movecurrentworkspacetomonitor,${direction}")
    #      directions);
  };
}
