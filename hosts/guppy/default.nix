#############################################################
#
#  Guppy - Remote Installation Test Lab
#  NixOS running on VirtualBox VM
#
###############################################################

{ inputs, ... }: {
  imports = [
    #################### Hardware Modules ####################

    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Required Configs ####################
    ./install-config.nix # disko spec
    # ./hardware-configuration.nix
    ../common/core

    #################### Optional Configs ####################
    ../common/optional/services/openssh.nix

    #################### Users to Create ####################
    ../common/users/ta

  ];

  #autoLogin.enable = true;
  #autoLogin.username = "ta";

  services.gnome.gnome-keyring.enable = true;

  networking = {
    hostName = "guppy";
    #networkmanager.enable = true;
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
