#############################################################
#
#  Ghost - Main Desktop
#  NixOS running on Ryzen 9 5900XT, Radeon RX 9070 XT, 64GB RAM
#
###############################################################

{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = lib.flatten [
    # ========== Hardware ==========
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
          # Services
          "services/logrotate.nix" # log rotation
          "services/openssh.nix" # allow remote SSH access
          "services/ollama.nix" # local llm
          "services/printing.nix" # CUPS

          # Misc
          "amdgpu_top.nix" # GPU monitor (not available in home-manager)
          "gaming.nix" # window manager
          "fonts.nix" # fonts
          #NOTE: disabling for now in favor of microvms. There is a network collision when using both
          # and I haven't been make much use of libvirt lately anyway
          #"libvirt.nix" # vm tools
          "mail-delivery.nix" # for sending email notifications
          "nvtop.nix" # GPU monitor (not available in home-manager)
          "obsidian.nix" # wiki
          "protonvpn.nix" # vpn
          "scanning.nix" # SANE and simple-scan
          "thunar.nix" # gui file manager
          "vlc.nix" # media player
          "yubikey.nix" # yubikey related packages and configs
          "zsa-keeb.nix" # Moonlander keeb flashing stuff
        ])
    ))
  ];

  introdus = {
    niri.enable = true; # Wayland compositor
    plymouth = {
      enable = true; # boot graphics
      theme = "loader";
    };
    services = {
      audio.enable = true;
      silent-sddm.enable = true; # desktop display manager
    };
  };
  # Additional settings not in introdus
  services.pipewire.jack.enable = true;

  # Bluetooth
  services.blueman.enable = true;

  hardware = {
    graphics.package = pkgs.unstable.mesa;
    graphics.package32 = pkgs.unstable.pkgsi686Linux.mesa; # force the same mesa for when steams requires separate system32 mesa dep
  };

  console.earlySetup = lib.mkDefault true;

  boot.initrd = {
    systemd.enable = true;
    kernelModules = [
      "amdgpu"
    ];
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      # When using plymouth, initrd can expand by a lot each time, so limit how many we keep around
      configurationLimit = lib.mkDefault 10;
      consoleMode = "max";
    };
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };
  boot = {
    kernelParams = [
      "amdgpu.ppfeaturemask=0xfffd3fff" # https://kernel.org/doc/html/latest/gpu/amdgpu/module-parameters.html#ppfeaturemask-hexint
      "amdgpu.dcdebugmask=0x400" # Allegedly might help with some crashes
      "split_lock_detect=off" # Alleged gaming perf increase
      "amdgpu.modeset=1" # explicitly have driver perform KMS (Kernel Mode Setting) during initialization to get higher resolution console output during boot
    ]
    ++ (lib.map (
      m: "video=${m.name}:${lib.toString m.width}x${lib.toString m.height}@${lib.toString m.refreshRate}"
    ) config.monitors);

    # Fix for XBox controller disconnects
    extraModprobeConfig = "options bluetooth disable_ertm=1 ";
  };

  environment.systemPackages = lib.attrValues {
    inherit (pkgs.unstable)
      vulkan-tools # vulkaninfo
      ;
  };

  #Firmwareupdater
  #  $ fwupdmgr update
  services.fwupd.enable = true;

  services.backup = {
    enable = true;
    borgBackupStartTime = "02:00:00";

    borgServer = "${config.hostSpec.networking.subnets.grove.hosts.moth.ip}";
    borgUser = "${config.hostSpec.primaryUsername}";
    borgPort = "${lib.toString config.hostSpec.networking.ports.tcp.moth}";

    borgRemotePath = "/run/current-system/sw/bin/borg";

    borgBackupPath = "/mnt/storage/backup/${config.hostSpec.primaryUsername}";
    borgNotifyFrom = "${config.hostSpec.email.notifier}";
    borgNotifyTo = "${config.hostSpec.email.backup}";

    borgBackupPaths = [
      "${config.hostSpec.home}"
    ];

    borgExcludes = [
      "${config.hostSpec.home}/.local/share/Steam"
    ];
  };

  # Connect our NUT client to the UPS on the network
  services.ups = {
    client.enable = true;
    name = "cyberpower";
    username = "nut";
    ip = config.hostSpec.networking.subnets.grove.hosts.moth.ip;
    powerDownTimeOut = (60 * 30); # 30m. UPS reports ~45min
  };

}
