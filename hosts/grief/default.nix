#############################################################
#
#  Grief - Dev Lab
#  NixOS running on Qemu VM
#
###############################################################

{ inputs, configLib, ... }: {
  imports = [
    #################### Disko Spec ####################
    inputs.disko.nixosModules.disko
    (configLib.relativeToRoot "hosts/common/disks/std-disk-config.nix")

    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Required Configs ####################
    ./hardware-configuration.nix
    (configLib.relativeToRoot "hosts/common/core")

    #################### Host-specific Optional Configs ####################
    (configLib.relativeToRoot "hosts/common/optional/yubikey")
    (configLib.relativeToRoot "hosts/common/optional/services/clamav.nix") # depends on optional/msmtp.nix
    (configLib.relativeToRoot "hosts/common/optional/msmtp.nix") # required for emailing clamav alerts
    (configLib.relativeToRoot "hosts/common/optional/services/openssh.nix")

    # Desktop
    (configLib.relativeToRoot "hosts/common/optional/services/greetd.nix") # display manager
    (configLib.relativeToRoot "hosts/common/optional/hyprland.nix") # window manager

    #################### Users to Create ####################
   (configLib.relativeToRoot "hosts/common/users/ta")

  ];
  # set custom autologin options. see greetd.nix for details
  # TODO is there a better spot for this?
  autoLogin.enable = true;
  autoLogin.username = "ta";

  services.gnome.gnome-keyring.enable = true;
  # TODO enable and move to greetd area? may need authentication dir or something?
  # services.pam.services.greetd.enableGnomeKeyring = true;

  networking = {
    hostName = "grief";
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

  # Fix to enable VSCode to successfully remote SSH on a client to a NixOS host
  # https://nixos.wiki/wiki/Visual_Studio_Code # Remote_SSH
  programs.nix-ld.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
