{ ... }:
let
  extraDisk1 = "cryptextra";
  extraDisk2 = "cryptvms";
  extraDisk3 = "cryptmedia1";
  extraDisk4 = "cryptmedia2";
in
{
  system.disks = {
    # 1TB /dev/nvme0n1
    primary = "/dev/disk/by-id/nvme-WDS100T3XHC-00SJG0_201274802169";
    primaryDiskoLabel = "cryptprimary";
    bootSize = "1G";
    luks.label = "cryptprimary";
    extraDisks = [
      # NOTE: the luks partition (e.g. `-part1`) needs to be specified in path
      {
        # 250GB /dev/nvme1n1
        name = extraDisk1;
        path = "/dev/disk/by-id/nvme-WDS250G3X0C-00SJG0_202604A00429-part1";
      }
      {
        # 500GB /dev/sdb
        name = extraDisk2;
        path = "/dev/disk/by-id/ata-WDC_WDS500G2B0A-00SM50_201723800798-part1";
      }
      {
        # 5.0TB /dev/sbc
        name = extraDisk3;
        path = "/dev/disk/by-id/wwn-0x50014ee260ee313a";
      }
      {
        # 5.0TB /dev/sda
        name = extraDisk4;
        path = "/dev/disk/by-id/wwn-0x50014ee260ee235e";
      }
    ];
  };
  #NOTE: The fstab entries are defined for extraDisks here instead of within the
  # disko part of nix-config/modules/hosts/nixos/disks.nix so that they aren't
  # formatted and partitioned by disko.
  # auto-unlocking the luks encryption is handled via the disks module though.
  fileSystems."/mnt/extra" = {
    device = "/dev/mapper/${extraDisk1}";
    fsType = "btrfs";
    options = [
      "subvol=@extra"
      "compress=zstd"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };
  fileSystems."/mnt/vms" = {
    device = "/dev/mapper/${extraDisk2}";
    fsType = "btrfs";
    options = [
      "subvol=@vms"
      "compress=zstd"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };
  fileSystems."/mnt/media1" = {
    device = "/dev/mapper/${extraDisk3}";
    fsType = "btrfs";
    options = [
      "subvol=@media1"
      "compress=zstd"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };
  fileSystems."/mnt/media2" = {
    device = "/dev/mapper/${extraDisk4}";
    fsType = "btrfs";
    options = [
      "subvol=@media2"
      "compress=zstd"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };
}
