{ config, ... }:
let
  ghostIP = config.hostSpec.networking.subnets.grove.hosts.ghost.ip;
in
{
  # mount nfs mediashare from ghost
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/mediashare" = {
    device = "${ghostIP}:/mnt/media1/mediashare/";
    fsType = "nfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "nofail"
      "x-systemd.device-timeout=15s"
    ];
  };
}
