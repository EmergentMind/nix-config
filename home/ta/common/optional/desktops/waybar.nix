{
  # Let it try to start a few more times
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target"; # NOTE = hyprland/default.nix stops graphical-session.target and starts hyprland-sessionl.target
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "DP-1"
          "DP-2"
          "DP-3"
          "HDMI-A-1"
        ];
        modules-left = [
          "hyprland/workspaces"
          #TODO waybar warning say these are unknown modules... need to customize below
          #          "hyprland/mode"
          #          "hyprland/taskbar"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          #"mpd"
          "tray"
          "clock"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        "pulseaudio" = {
          "format" = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon}";
          "format-muted" = "";
          "format-icons" = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "phone-muted" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              ""
              ""
            ];
          };
          "scroll-step" = 1;
          "on-click" = "pavucontrol";
          "ignored-sinks" = [ "Easy Effects Sink" ];
        };
        #        "mpd" = {
        #    "format" = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ";
        #    "format-disconnected" = "Disconnected ";
        #    "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
        #    "interval" = 10;
        #    "consume-icons" = {
        #        "on" = " "; # Icon shows only when "consume" is on
        #    };
        #    "random-icons" = {
        #        "off" = "<span color=\"#f53c3c\"></span>"; #Icon grayed out when "random" is off
        #        "on" = " ";
        #    };
        #    "repeat-icons" = {
        #        "on" = " ";
        #    };
        #    "single-icons" = {
        #        "on" = "1 ";
        #    };
        #    "state-icons" = {
        #        "paused" = "";
        #        "playing" = "";
        #    };
        #    "tooltip-format" = "MPD (connected)";
        #    "tooltip-format-disconnected" = "MPD (disconnected)";
        #};
      };
    };
  };
}
