{
  config,
  lib,
  pkgs,
  ...
}:
let
  commonDeps = with pkgs; [
    coreutils
    gnugrep
    systemd
  ];
  mkScript =
    {
      name ? "script",
      deps ? [ ],
      script ? "",
    }:
    lib.getExe (
      pkgs.writeShellApplication {
        inherit name;
        text = script;
        runtimeInputs = commonDeps ++ deps;
      }
    );
in
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
      #
      # ========== Main Bar ==========
      #
      mainBar = {
        layer = "top";
        position = "top";
        height = 36; # 36 is the minimum height required by the modules

        output = (map (m: "${m.name}") (config.monitors));

        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right =
          if config.hostSpec.isMobile then
            [
              "gamemode"
              "pulseaudio"
              #"mpd"
              "tray"
              # TODO: preferring applets for network and bluetooth instead of these
              # modules. consider removing in future.
              #"network"
              #"bluetooth"
              "battery"
              "backlight"
              "clock#time"
              "clock#date"
            ]
          else
            [
              "gamemode"
              "pulseaudio"
              #"mpd"
              "tray"
              #"network"
              "clock#time"
              "clock#date"
            ];

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
        "bluetooth" = {
          "format" = " {icon} ";
          "format-disabled" = "";
          "format-connected" = "{device_battery_percentage}% {icon}";
          "icon-size" = 30;
          "format-icons" = {
            "off" = "󰂲";
            "on" = "󰂯";
            "connected" = "󰂱";
          };
          "on-click" = "blueman-manager";
        };
        "network" = {
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr} ";
          "format-disconnected" = "Disconnected ⚠";
          "tooltip-format" =
            "{essid} {ipaddr}\n{ifname} via {gwaddr} {essid}\nUP:{bandwidthUpBits}mbps  DOWN:{bandwidthDownBits}mbps {signalStrength}";
          "on-click" = "nm-connection-editor";
        };
        "pulseaudio" = {
          "format" = "{volume}% {icon}";
          "format-source" = "Mic ON";
          "format-source-muted" = "Mic OFF";
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
        "backlight" = {
          tooltip = false;
          format = "{}% ";
          interval = 5;
          on-scroll-up = mkScript {
            deps = [ pkgs.brightnessctl ];
            script = "brightnessctl set 1%+";
          };
          on-scroll-down = mkScript {
            deps = [ pkgs.brightnessctl ];
            script = "brightnessctl set 1%-";
          };
        };
        "battery" = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        #"mpd" = {
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
