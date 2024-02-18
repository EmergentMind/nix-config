#############################################################
#
#  Gusto - Home Theatre
#  NixOS running on ASUS VivoPC VM40B-S081M
#
###############################################################

{ inputs, ... }: {
  imports = [
    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel

    #################### Required Configs ####################
    ../common/core
    ./hardware-configuration.nix

    #################### Host-specific Optional Configs ####################
    ../common/optional/services/openssh.nix # allow remote SSH access

    ../common/optional/xfce.nix # window manager
    ../common/optional/pipewire.nix # audio
    ../common/optional/smbclient.nix # mount the ghost mediashare
    ../common/optional/vlc.nix # media player

    #################### Users to Create ####################
    ../common/users/ta
    ../common/users/media
  ];

  # Enable some basic X server options
  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "media";
  };
  # TODO this might be redudnant
  services.xserver.xkb.layout = "us";

  networking = {
    hostName = "gusto";
    enableIPv6 = false;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
