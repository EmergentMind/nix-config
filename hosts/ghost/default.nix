#############################################################
#
#  Ghost - Main Desktop
#  NixOS running on Ryzen 5 3600X, Radeon RX 5700 XT, 64GB RAM
#
###############################################################

{ inputs, configLib, ... }:
{
  imports =
    [
      #################### Every Host Needs This ####################
      ./hardware-configuration.nix

      #################### Hardware Modules ####################
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd

      #################### Disk Layout ####################
      inputs.disko.nixosModules.disko
      (configLib.relativeToRoot "hosts/common/disks/ghost.nix")
    ]
    ++ (map configLib.relativeToRoot [
      #################### Required Configs ####################
      "hosts/common/core"

      #################### Host-specific Optional Configs ####################
      "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      #"hosts/common/optional/services/clamav.nix" # av scanner
      "hosts/common/optional/libvirt.nix" # vm tools
      "hosts/common/optional/nvtop.nix" # GPU monitor (not available in home-manager)
      "hosts/common/optional/obsidian.nix" # wiki
      "hosts/common/optional/thunar.nix" # file manager
      "hosts/common/optional/audio.nix" # pipewire and cli controls
      "hosts/common/optional/vlc.nix" # media player
      "hosts/common/optional/yubikey"
      "hosts/common/optional/gaming.nix"
      "hosts/common/optional/zsa-keeb.nix" # Moonlander Keeb flashing stuff

      #################### Desktop ####################
      "hosts/common/optional/services/greetd.nix" # display manager
      "hosts/common/optional/hyprland.nix" # window manager
      "hosts/common/optional/waypaper.nix" # wallpaper manage (nitrogen analog for wayland)

      #################### Users to Create ####################
      "hosts/common/users/ta"
    ]);

  networking = {
    hostName = "ghost";
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

  #FIXME FINISH THIS
  # needed unlock LUKS on secondary drives
  # https://wiki.nixos.org/wiki/Full_Disk_Encryption#Unlocking_secondary_drives
  # /dev/nvme1n1p1 UUID=569e2951-1957-4387-8b51-f445741b02b6
  # /dev/sda1 UUID=273039ba-b3f2-464a-af55-03c74644e62f
  environment.etc.crypttab.text = ''
    cryptextra UUID=569e2951-1957-4387-8b51-f445741b02b6 /luks-secondary-unlock.key
    cryptvms UUID=273039ba-b3f2-464a-af55-03c74644e62f /luks-secondary-unlock.key
  '';

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
