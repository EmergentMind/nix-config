#############################################################
#
#  Gusto - Home Theatre
#  NixOS running on ASUS VivoPC VM40B-S081M
#
###############################################################

{ inputs, configLib, ... }:
{
  imports =
    [
      #################### Every Host Needs This ####################
      ./hardware-configuration.nix

      #################### Hardware Modules ####################
      inputs.hardware.nixosModules.common-cpu-intel
      #inputs.hardware.nixosModules.common-gpu-intel #This is apparenlty already declared in `/nix/store/HASH-source/common/gpu/intel

      #TODO move gusto to disko
    ]
    ++ (map configLib.relativeToRoot [

      #################### Required Configs ####################
      "hosts/common/core"

      #################### Host-specific Optional Configs ####################
      "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      "hosts/common/optional/xfce.nix" # window manager until I get hyprland configured
      "hosts/common/optional/pipewire.nix" # audio
      "hosts/common/optional/smbclient.nix" # mount the ghost mediashare
      "hosts/common/optional/vlc.nix" # media player

      #################### Users to Create ####################
      "hosts/common/users/ta"
      "hosts/common/users/media"
    ]);

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
