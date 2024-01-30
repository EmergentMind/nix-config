#############################################################
#
#  Gusto - Home Theatre
#  NixOS running on ASUS VivoPC VM40B-S081M
#
###############################################################

{ inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel

    #################### Required Configs #################### 
    ../common/core 
    ./hardware-configuration.nix

    #################### Host-specific Optional Configs #################### 
    ../common/optional/services/clamav.nix # depends on optional/msmtp.nix
    ../common/optional/msmtp.nix # required for emailing clamav alerts
    ../common/optional/services/openssh.nix # allow remote SSH access
    ../common/optional/pipewire.nix # audio

    #################### Users to Create #################### 
    ../common/users/ta
   # TODO stage 2
   # ../common/users/media

  ];

  # Automatically log in the media user
  # TODO stage 2: handle auto login from greetd
  # services.getty.autologinUser = "media";

  networking = {
    hostName = "gusto";
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

  # TODO stage 2: Can likely remove this because any vscode remoting would go to lab for changes instead
  # Fix to enable VSCode to successfully remote SSH on a client to a NixOS host
  # https://nixos.wiki/wiki/Visual_Studio_Code#Remote_SSH
  programs.nix-ld.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
