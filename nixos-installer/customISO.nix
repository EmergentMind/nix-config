{ pkgs, lib, config, configLib, ... }:
let
  pubKeys = lib.filesystem.listFilesRecursive (configLib.relativeToRoot "keys/");
in
{
  # The default compression-level is (6) and takes quite(>30m). 3 takes <2m
  #  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  # FIXME: Reference generic nix file
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  services = {
    #    openssh.settings.PermitRootLogin = lib.mkForce "no";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [ "btrfs" "vfat" ];
  };

  networking = {
    hostName = "iso";
  };

  systemd = {
    services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    # gnome power settings do not turn off screen
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  # FIXME This should come from users/ta/nixos.nix, but it uses sops which I don't want to use for iso
  # TODO switch ta to configVars
  users.users.root = {
    password = "nixos";

    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      rsync;
  };
}
