#############################################################
#
#  Gusto - Home Theatre
#  NixOS running on ASUS VivoPC VM40B-S081M
#
###############################################################

{ inputs, configLib, ... }: {
  imports = [
    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-intel
    #inputs.hardware.nixosModules.common-gpu-intel  #This is apparenlty already declared in `/nix/store/HASH-source/common/gpu/intel

    #################### Required Configs ####################
  #TODO move gusto to disko
    ./hardware-configuration.nix
    (configLib.relativeToRoot "hosts/common/core")

    #################### Host-specific Optional Configs ####################
    (configLib.relativeToRoot "hosts/common/optional/services/openssh.nix") # allow remote SSH access
    (configLib.relativeToRoot "hosts/common/optional/xfce.nix") # window manager
    (configLib.relativeToRoot "hosts/common/optional/pipewire.nix") # audio
    (configLib.relativeToRoot "hosts/common/optional/smbclient.nix") # mount the ghost mediashare
    (configLib.relativeToRoot "hosts/common/optional/vlc.nix") # media player

    #################### Users to Create ####################
    (configLib.relativeToRoot "hosts/common/users/ta")
    (configLib.relativeToRoot "hosts/common/users/media")
  ];

  # Enable some basic X server options
  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "media";
  };

  networking = {
    hostName = "gusto";
    networkmanager.enable = true;
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
