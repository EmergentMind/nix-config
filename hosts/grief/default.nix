#############################################################
#
#  Grief - Dev Lab
#  NixOS running on Qemu VM
#
###############################################################

{ inputs, configLib, ... }: {
  imports = [
    #################### Every Host Needs This ####################
    ./hardware-configuration.nix
    
    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Disk Layout ####################
    inputs.disko.nixosModules.disko
    (configLib.relativeToRoot "hosts/common/disks/std-disk-config.nix")
    {
      _module.args = {
        disk = "/dev/vda";
        withSwap = true;
      };
    }
  ]
  ++ (map configLib.relativeToRoot [
    #################### Required Configs ####################
    "hosts/common/core"

    #################### Host-specific Optional Configs ####################
    "hosts/common/optional/yubikey"
    "hosts/common/optional/services/clamav.nix" # depends on optional/msmtp.nix
    "hosts/common/optional/msmtp.nix" # required for emailing clamav alerts
    "hosts/common/optional/services/openssh.nix"

    # Desktop
    "hosts/common/optional/services/greetd.nix" # display manager
    "hosts/common/optional/hyprland.nix" # window manager

    #################### Users to Create ####################
    "hosts/common/users/ta"
  ]);
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

  # This is a fix to enable VSCode to successfully remote SSH on a client to a NixOS host
  # https://nixos.wiki/wiki/Visual_Studio_Code # Remote_SSH
  programs.nix-ld.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
