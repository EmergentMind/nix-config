# Core functionality for every nixos host
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.introdus.nixosModules.default
  ];

  # Database for aiding terminal-based programs
  environment.enableAllTerminfo = true;
  # Enable firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # This should be handled by config.security.pam.sshAgentAuth.enable
  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
    # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

  # Enable automatic login for the user.
  services.displayManager = lib.optionalAttrs config.hostSpec.useWindowManager {
    autoLogin.enable = false;
    autoLogin.user = config.hostSpec.primaryDesktopUsername;
    defaultSession = config.hostSpec.defaultDesktop;
  };

  services.gnome.gnome-keyring.enable = config.hostSpec.useWindowManager;

  #
  # ========== Generation Pinning ==========
  #
  # Pin a boot entry if it exists. In order to generate the
  # pinned-boot-entry.conf for a "stable" generation run: 'just pin' and then
  # rebuild. See the pin recipe in justfile for more information
  boot.loader.systemd-boot.extraEntries =
    let
      pinned = lib.custom.relativeToRoot "hosts/nixos/${config.hostSpec.hostName}/pinned-boot-entry.conf";
    in
    lib.optionalAttrs (config.boot.loader.systemd-boot.enable && lib.pathExists pinned) {
      "pinned-stable.conf" = lib.readFile pinned;
    };

  # don't wait for dhcpd on boot
  networking.dhcpcd.wait = "background";
  # Stop blocking on network interfaces not needed for boot
  systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  environment = {
    localBinInPath = true;

    # From https://github.com/matklad/config/blob/master/hosts/default.nix
    etc."xdg/user-dirs.defaults".text = ''
      DOWNLOAD=downloads
      TEMPLATES=tmp
      PUBLICSHARE=/var/empty
      DOCUMENTS=doc
      MUSIC=media/audio
      PICTURES=media/images
      VIDEOS=media/video
      DESKTOP=.desktop
    '';
  };

  #
  # ========== Nix Helper ==========
  #
  # Provides better build output and will also handle garbage collection in place of standard nix gc (garbage collection)
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 20d --keep 20";
    };
    flake = "${config.hostSpec.home}/dev/nix/nix-config";
  };

  #
  # ========== Localization ==========
  #
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault config.hostSpec.timeZone;

  system.stateVersion = "23.05";
}
