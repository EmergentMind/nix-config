#############################################################
#
#  Grief - Dev Lab 
#  NixOS running on VirtualBox VM
#
###############################################################

{ inputs, ... }: {
  imports = [
    #################### Hardware Modules #################### 
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Required Configs #################### 
    ../common/core 
    ./hardware-configuration.nix

    #################### Host-specific Optional Configs #################### 
    # TODO yubi
    ../common/optional/yubikey
    ../common/optional/services/clamav.nix # depends on optional/msmtp.nix
    ../common/optional/msmtp.nix #required for emailing clamav alerts
    ../common/optional/services/openssh.nix

    # Desktop
    ../common/optional/services/greetd.nix # display manager
    ../common/optional/hyprland.nix # window manager

    #################### Users to Create #################### 
    ../common/users/ta

  ];
  # set custom autologin options. see greetd.nix for details
  # TODO is there a better spot for this?
  autoLogin.enable = true;
  autoLogin.username = "ta";

  services.gnome.gnome-keyring.enable = true;
  #TODO enable and move to greetd area? may need authentication dir or something? 
  #services.pam.services.greetd.enableGnomeKeyring = true;

  networking = {
    hostName = "grief";
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
  
  # VirtualBox settings for Hyprland to display correctly
  #environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  #environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE = "1";

  # Fix to enable VSCode to successfully remote SSH on a client to a NixOS host
  # https://nixos.wiki/wiki/Visual_Studio_Code#Remote_SSH
  programs.nix-ld.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
