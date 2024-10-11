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
        height = 36; # 36 is the minimum height required by the modules
        output = [
          "DP-1"
          "DP-2"
          "DP-3"
          "HDMI-A-1"
        ];
        modules-left = [
          "hyprland/workspaces"
          "hyprland/mode"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "gamemode"
          "pulseaudio"
          #"mpd"
          "tray"
          "network"
          "clock#time"
          "clock#date"
        ];

        #
        # ========= Modules =========
        #

        #TODO
        #"hyprland/window" ={};

        "hyprland/workspaces" = {
          all-outputs = false;
          disable-scroll = true;
          on-click = "actviate";
          show-special = true; # display special workspaces along side regular ones (scratch for example)
        };
        "clock#time" = {
          interval = 1;
          format = "{:%H:%M}";
          tooltip = false;
        };
        "clock#date" = {
          interval = 10;
          format = "{:%d.%b.%y.%a}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        "gamemode" = {
          "format" = "{glyph}";
          "format-alt" = "{glyph} {count}";
          "glyph" = "";
          "hide-not-running" = true;
          "use-icon" = true;
          "icon-name" = "input-gaming-symbolic";
          "icon-spacing" = 4;
          "icon-size" = 20;
          "tooltip" = true;
          "tooltip-format" = "Games running: {count}";
        };
        "network" = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          "format" = "{volume}% {icon}";
          #              "format-source" = "Mic ON";
          #              "format-source-muted" = "Mic OFF";
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
        "tray" = {
          spacing = 10;
        };
      };
    };
  };
}
