#NOTE actions prepended with `hy3;` are specific to the hy3 hyprland plugin
{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    #
    # ========== Mouse Bindings==========
    #

    bindm = [
      # hold alt + leftlclick  to move/drag active window
      "ALT,mouse:272,movewindow"
      # hold alt + rightclick to resize active window
      "ALT,mouse:273,resizewindow"
    ];
    bindn = [
      # allow tab selection using mouse
      ", mouse:272, hy3:focustab, mouse"
    ];

    #
    # ========== Key Bindings==========
    #
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
        terminal = config.home.sessionVariables.TERM;
        editor = config.home.sessionVariables.EDITOR;
        #playerctl = lib.getExe pkgs.playerctl; # installed via /home/common/optional/desktops/playerctl.nix
        #swaylock = "lib.getExe pkgs.swaylock;
        #makoctl = "${config.services.mako.package}/bin/makoctl";
        #gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
        #notify-send = "${pkgs.libnotify}/bin/notify-send";
        #gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
        #xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
        #defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";
        #browser = defaultApp "x-scheme-handler/https";

      in
      lib.flatten [

        #
        # ========== Quick Launch ==========
        #
        "SUPER,space,exec,rofi -show run"
        "SUPER_SHIFT,space,exec,rofi -show drun"
        "SUPER,s,exec,rofi -show ssh"
        "ALT,tab,exec,rofi -show window"

        "ALT,Return,exec,${terminal}"
        "CTRL_ALT,v,exec,${terminal} ${editor}"
        "CTRL_ALT,f,exec,thunar"

        #
        # ========== Screenshotting ==========
        #
        # TODO check on status of flameshot and multimonitor wayland. as of Oct 2024, it's a clusterfuck
        # so resorting to grimblast in the meantime
        #"CTRL_ALT,p,exec,flameshot gui"
        "CTRL_ALT,p,exec,grimblast --notify --freeze copy area"
        ",Print,exec,grimblast --notify --freeze copy area"

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
        # ========== Windows and Groups ==========
        #
        # Close the focused/active window
        "SHIFTALT,q,hy3:killactive"

        #FIXME play around with fullscreenstate to get a setting that works with maximizing sec cams in window
        # Fullscreen
        "ALT,f,fullscreen,0" # 0 - fullscreen (takes your entire screen), 1 - maximize (keeps gaps and bar(s))

        # Float and pin
        "SHIFTALT,space,togglefloating"
        "SHIFTALT, p, pin, active" # pins a floating window (i.e. show it on all workspaces)

        # Resize active window 5 pixels in direction
        "Control_L&Shift_L&Alt_L, h, resizeactive, -5 0"
        "Control_L&Shift_L&Alt_L, j, resizeactive, 0 5"
        "Control_L&Shift_L&Alt_L, k, resizeactive, 0 -5"
        "Control_L&Shift_L&Alt_L, l, resizeactive, 5 0"

        # Splits groups
        "ALT,v,hy3:makegroup,v" # make a vertical split
        "SHIFTALT,v,hy3:makegroup,h" # make a horiztonal split
        "ALT,x,hy3:changegroup,opposite" # toggle btwn splits if untabbed
        "ALT,s,togglesplit"

        # Tab groups
        "ALT,g,hy3:changegroup,toggletab" # tab or untab the group
        #"ALT,t,lockactivegroup,toggle"
        "ALT,apostrophe,changegroupactive,f"
        "SHIFTALT,apostrophe,changegroupactive,b"

        #
        # ========== Workspaces ==========
        #
        # Change workspace
        (map (n: "ALT,${n},workspace,name:${n}") workspaces)

        # Special/scratch
        "ALT,y, togglespecialworkspace"
        "SHIFTALT,y,movetoworkspace,special"

        # Move window to workspace
        (map (n: "SHIFTALT,${n},hy3:movetoworkspace,name:${n}") workspaces)

        # Move focus from active window to window in specified direction
        (lib.mapAttrsToList (key: direction: "ALT,${key},hy3:movefocus,${direction},warp") directions)

        # Move windows
        (lib.mapAttrsToList (key: direction: "SHIFTALT,${key},hy3:movewindow,${direction}") directions)

        # Move workspace to monitor in specified direction
        (lib.mapAttrsToList (
          key: direction: "CTRLSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        ) directions)

        #
        # ========== Misc ==========
        #
        "SHIFTALT,r,exec,hyprctl reload" # reload the configuration file
      ];
  };
}
