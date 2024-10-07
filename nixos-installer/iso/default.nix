{
  pkgs,
  lib,
  configLib,
  configVars,
  ...
}:
let
  sshPort = configVars.networking.ports.tcp.ssh;
in
{
  imports = [ (configLib.relativeToRoot "hosts/common/users/${configVars.username}") ];

  # The default compression-level is (6) and takes too long on some machines (>30m). 3 takes <2m
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  # NOTE this could be referenced in a generic nix file but it's not worth the extra overhead required elsewhere to do it
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  services = {
    qemuGuest.enable = true;
    openssh = {
      ports = [ sshPort ];
      settings.PermitRootLogin = lib.mkForce "yes";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
    ];
  };

  networking = {
    hostName = "iso";
  };

  systemd = {
    services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    # gnome power settings to not turn off screen
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
