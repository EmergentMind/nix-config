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
    ../common/optional/services/clamav.nix # depends on optional/msmtp.nix
    ../common/optional/msmtp.nix # required for emailing clamav alerts
    ../common/optional/services/openssh.nix # allow remote SSH access

    ../common/optional/xfce.nix # window manager
    ../common/optional/pipewire.nix # audio

    #################### Users to Create #################### 
    ../common/users/ta
    ../common/users/media
  ];

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
