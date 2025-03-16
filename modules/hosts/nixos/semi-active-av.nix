# Based on https://github.com/coreyoconnor/nix_configs/blob/b59dbb77ee38e515f4099f8fb0feb5e2286a5b34/modules/semi-active-av.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.semi-active-av;
  sus-user-dirs = [
    "downloads"
    ".mozilla"
  ];
  all-normal-users = lib.attrsets.filterAttrs (
    username: config: config.isNormalUser
  ) config.users.users;
  all-sus-dirs = builtins.concatMap (
    dir: lib.attrsets.mapAttrsToList (username: config: config.home + "/" + dir) all-normal-users
  ) sus-user-dirs;
  all-user-folders = lib.attrsets.mapAttrsToList (username: config: config.home) all-normal-users;
  all-system-folders = [
    "/boot"
    "/etc"
    "/nix"
    "/opt"
    "/root"
    "/usr"
  ];

  clamav-notify = pkgs.writeScript "clamav-notify" ''
    #!/bin/sh
    ALERT="Signature detected by clamav: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"
    # Send an alert to all graphical users.
    for ADDRESS in /run/user/*; do
        USERID=''${ADDRESS#/run/user/}
        sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" ${pkgs.libnotify}/bin/notify-send -u critical -i dialog-warning "Suspicious file" "$ALERT"
    done
    TMPDIR=$(mktemp -d)
    cat >"$TMPDIR"/clamav-mail.txt <<-EOF
        From:${config.hostSpec.email.notifier}
        Subject: [$(hostname)] $(date) Suspicious file detected!

        $ALERT
        EOF
          msmtp -t $(hostname).alerts.net@${config.hostSpec.domain} <"$TMPDIR"/clamav-mail.txt
  '';
in
{
  options = {
    semi-active-av = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo = {
      extraConfig = ''
        clamav ALL = (ALL) NOPASSWD: SETENV: ${pkgs.libnotify}/bin/notify-send
      '';
    };

    services.clamav.daemon = {
      enable = true;

      settings = {
        OnAccessIncludePath = all-sus-dirs;
        OnAccessPrevention = false;
        OnAccessExtraScanning = true;
        OnAccessExcludeUname = "clamav";
        VirusEvent = "${clamav-notify}";
        User = "clamav";
      };
    };
    services.clamav.updater.enable = true;

    systemd.services.clamav-clamonacc = {
      description = "ClamAV daemon (clamonacc)";
      after = [ "clamav-freshclam.service" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ "/etc/clamav/clamd.conf" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.systemd}/bin/systemd-cat --identifier=av-scan ${pkgs.clamav}/bin/clamonacc -F --fdpass";
        PrivateTmp = "yes";
        PrivateDevices = "yes";
        PrivateNetwork = "yes";
      };
    };

    systemd.timers.av-user-scan = {
      description = "scan normal user directories for suspect files";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Unit = "av-user-scan.service";
      };
    };

    systemd.services.av-user-scan = {
      description = "scan normal user directories for suspect files";
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemd-cat --identifier=av-scan ${pkgs.clamav}/bin/clamdscan --quiet --recursive --fdpass ${toString all-user-folders}";
      };
    };

    systemd.timers.av-all-scan = {
      description = "scan all directories for suspect files";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "monthly";
        Unit = "av-all-scan.service";
      };
    };

    systemd.services.av-all-scan = {
      description = "scan all directories for suspect files";
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.systemd}/bin/systemd-cat --identifier=av-scan ${pkgs.clamav}/bin/clamdscan --quiet --recursive --fdpass ${toString all-system-folders}
        '';
      };
    };
  };
}
