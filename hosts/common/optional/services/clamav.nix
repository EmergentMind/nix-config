#
# FIXME check for dependency somehow? Requires the msmtp.nix option for email notifications
#

{
  pkgs,
  lib,
  config,
  ...
}:
let
  # FIXME
  # isEnabled = name: predicate: {
  # assertion = predicate;
  # message = "${name} should be enabled for the clamav.nix config to work correctly.";
  # };

  # Function to notify users and admin when a suspicious file is detected
  notify-all-users = pkgs.writeScript "notify-all-users-of-sus-file" ''
    #!/usr/bin/env bash
    ALERT="Signature detected by clamav: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"
    # Send an alert to all graphical users.
    for ADDRESS in /run/user/*; do
        USERID=''${ADDRESS#/run/user/}
       /run/wrappers/bin/sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" ${pkgs.libnotify}/bin/notify-send -i dialog-warning "Suspicious file" "$ALERT"
    done

    echo -e "To:$(hostname).alerts.net@hexagon.cx\n\nSubject: Suspicious file on $(hostname)\n\n$ALERT" | msmtp -a default alerts.net@hexagon.cx
  '';
in
{
  # FIXME
  # assertions = lib.mapAttrsToList isEnabled {
  # "hosts/common/optional/msmtp" = config.msmtp.enable;
  # };

  security.sudo = {
    extraConfig = ''
      clamav ALL = (ALL) NOPASSWD: SETENV: ${pkgs.libnotify}/bin/notify-send
    '';
  };

  services = {
    clamav = {
      daemon = {
        enable = true;
        settings = {
          # ClamAV configuration. Refer to <https://linux.die.net/man/5/clamd.conf>, for details on supported values.
          OnAccessPrevention = false;
          OnAccessExtraScanning = true;
          OnAccessExcludeUname = "clamav";
          VirusEvent = "${notify-all-users}";
          User = "clamav";
        };
      };
      updater = {
        enable = true;
        interval = "daily";
        frequency = 2;
        settings = {
          # Refer to <https://linux.die.net/man/5/freshclam.conf>,for details on supported values.
        };
      };
      # # TODO stage 3 checkback - this isn't currently available in stable but looks to be coming down the pipe https://github.com/NixOS/nixpkgs/commits/master/nixos/modules/services/security/clamav.nix
      # fangfrisch = {
      #   enable = true;
      #   interval = "daily";
      # };
      # scanner = {
      #   # By default his runs using 10 cores, be sure
      #   enable = true;
      #   interval = "*-*-* 04:00:00"; # default
      #   scanDirectories = [
      #     # these are currently defaults from the nixos pkg maintainer for everything he thought was valid for nixos
      #     "/home" "/var/lib" "/tmp" "/etc" "/var/tmp"
      #   ];
      # };
    };
  };
}
