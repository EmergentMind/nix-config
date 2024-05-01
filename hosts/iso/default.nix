{ pkgs, lib, config, configLib, configVars, ... }:
{
  # FIXME: We will want to override the username probably
  imports = [
    (configLib.relativeToRoot "hosts/common/users/${configVars.primaryUser}")
  ];

  # The default compression-level is (6) and takes too long on some machines (>30m). 3 takes <2m
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

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
#    qemuGuest.enable = true;
    openssh = {
      ports = [22]; # FIXME: Make this use configVars.networking
      settings.PermitRootLogin = lib.mkForce "yes";
    };
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
    # gnome power settings to not turn off screen
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  # FIXME This should come from users/ta/nixos.nix, but it uses sops which I don't want to use for iso
  # TODO switch ta to configVars
  users.users.${configVars.primaryUser} = {
    isNormalUser = true;

    hashedPassword = "";
    extraGroups = [ "wheel" ];
  };

  # root's ssh key are mainly used for remote deployment
  users.extraUsers.root = {
    inherit (config.users.users.${configVars.primaryUser}) hashedPassword;
    openssh.authorizedKeys.keys = config.users.users.${configVars.primaryUser}.openssh.authorizedKeys.keys;
  };

  #environment.systemPackages = builtins.attrValues {
    #inherit (pkgs)
      #rsync;
  #};
}
