#############################################################
#
#  Grovr - sa laptop
#  NixOS running on TODO
#
###############################################################

{
  inputs,
  lib,
  ...
}:
{
  imports = lib.flatten [
    #
    # ========== Hardware ==========
    #
    inputs.nixos-facter-modules.nixosModules.facter
    { config.facter.reportPath = ./facter.json; }

    #
    # ========== Modules ==========
    #
    (lib.custom.scanPaths ./.) # Load all host-specific *.nix files

    (map lib.custom.relativeToRoot (
      # ========== Required modules ==========
      [
        "hosts/common/core"
      ]
      ++
        # ========== Optional common modules ==========
        (map (f: "hosts/common/optional/${f}") [
          # Desktop environment and login manager
          "gnome.nix"

          # Services
          "services/openssh.nix" # allow remote SSH access

          # Network Mgmt
          "nfs-ghost-mediashare.nix" # mount the ghost mediashare

          # Misc
          "fonts.nix" # fonts
          "vlc.nix" # media player
        ])
    ))
  ];

  introdus = {
    plymouth = {
      enable = true; # boot graphics
      theme = "pixels";
    };
    services = {
      audio.enable = true;
      silent-sddm.enable = true; # desktop display manager
    };
  };

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot = {
    enable = true;
    # When using plymouth, initrd can expand by a lot each time, so limit how
    # many we keep around
    configurationLimit = lib.mkDefault 10;
    consoleMode = "max";
  };
  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # ========== Auto-login as regular user ==========
  services.displayManager.autoLogin = {
    enable = lib.mkForce true;
    user = lib.mkForce "clara";
  };
  services.displayManager.sddm.autoLogin = {
    relogin = true;
  };

  # ========== autosshTunnel ==========
  tunnels.cakes = {
    enable = true;
    sopsEntry = "keys/ssh/meek";
    keyPath = "/etc/ssh/id_meek";
  };

  #Firmwareupdater
  #  $ fwupdmgr update
  services.fwupd.enable = true;
}
