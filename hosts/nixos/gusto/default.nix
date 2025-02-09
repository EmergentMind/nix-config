#############################################################
#
#  Gusto - Home Theatre
#  NixOS running on Intel N95 based mini PC
#
###############################################################

{
  inputs,
  lib,
  ...
}:
{
  imports = lib.flatten [
    #
    # ========== Hardware ==========
    #
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-intel
    #inputs.hardware.nixosModules.common-gpu-intel #This is apparently already declared in `/nix/store/HASH-source/common/gpu/intel

    #
    # ========== Disk Layout ==========
    #
    inputs.disko.nixosModules.disko
    (lib.custom.relativeToRoot "hosts/common/disks/btrfs-disk.nix")
    {
      _module.args = {
        disk = "/dev/nvme0n1";
        withSwap = true;
        swapSize = 8;
      };
    }

    #
    # ========== Misc Inputs ==========
    #
    #inputs.stylix.nixosModules.stylix

    (map lib.custom.relativeToRoot [
      #
      # ========== Required Configs ==========
      #
      "hosts/common/core"

      #
      # ========== Non-Primary Users to Create ==========
      #
      "hosts/common/users/media"

      #
      # ========== Optional Configs ==========
      #
      "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      "hosts/common/optional/xfce.nix" # window manager
      "hosts/common/optional/audio.nix" # pipewire and cli controls
      "hosts/common/optional/smbclient.nix" # mount the ghost mediashare
      "hosts/common/optional/vlc.nix" # media player
    ])
  ];

  #
  # ========== Host Specification ==========
  #

  hostSpec = {
    hostName = "gusto";
    useYubikey = lib.mkForce true;
  };

  # Enable some basic X server options
  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm.enable = true;
  };

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "media";
  };

  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
