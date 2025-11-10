# Core functionality for every nixos host
{ config, lib, ... }:
{
  # Database for aiding terminal-based programs
  environment.enableAllTerminfo = true;
  # Enable firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  # This should be handled by config.security.pam.sshAgentAuth.enable
  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
    # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

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
    lib.optionalAttrs (config.boot.loader.systemd-boot.enable && builtins.pathExists pinned) {
      "pinned-stable.conf" = builtins.readFile pinned;
    };

  #
  # ========== Nix Helper ==========
  #
  # Provides better build output and will also handle garbage collection in place of standard nix gc (garbage collection)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 20";
    flake = "${config.hostSpec.home}/src/nix/nix-config";
  };

  #
  # ========== Localization ==========
  #
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault config.hostSpec.timeZone;
}
