# IMPORTANT: This is used by NixOS and nix-darwin so options must exist in both!
{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  isDarwin,
  secrets,
  ...
}:
let
  platform = if isDarwin then "darwin" else "nixos";
  platformModules = "${platform}Modules";
in
{
  imports = lib.flatten [
    inputs.home-manager.${platformModules}.home-manager
    inputs.sops-nix.${platformModules}.sops
    inputs.disko.${platformModules}.disko
    inputs.nix-index-database.${platformModules}.nix-index
    { programs.nix-index-database.comma.enable = true; } # NOTE: don't enable in hm as well because it will barf eventually

    (map lib.custom.relativeToRoot [
      "modules/hosts/common"
      "modules/hosts/${platform}"

      "hosts/common/core/${platform}.nix"
      "hosts/common/core/keyd.nix"
      "hosts/common/core/sops.nix" # Core because it's used for backups, mail

      "hosts/common/users/"
    ])
  ];

  #
  # ========== Core Host Specifications ==========
  #
  hostSpec = {
    primaryUsername = lib.mkDefault "ta";
    users = [ "ta" ];
    handle = "emergentmind";
    inherit (secrets)
      domain
      email
      userFullName
      networking
      ;
  };

  networking.hostName = config.hostSpec.hostName;

  # System-wide packages, in case we log in as root
  environment.systemPackages = [ pkgs.openssh ];

  # If there is a conflict file that is backed up, use this extension
  home-manager.backupFileExtension = "bk";

  #NOTE: comments below were an attempt at preemptively create /mnt
  # to mitigate quirk with secondary drives that are being mounted by
  # systemd for nfs prior to /mnt being created elsewhere
  # didn't seem to make a difference
  # systemd.tmpfiles.rules = [
  #   "d /mnt 0755 root root - -"
  #   "d /mnt/media1  0755 root root - -"
  #   "d /mnt/media2 0755 root root - -"
  # ];

  #
  # ========== Overlays ==========
  #
  nixpkgs = {
    overlays = [
      outputs.overlays.default
      inputs.introdus.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  #
  # ========== Basic Shell Enablement ==========
  #
  # On darwin it's important this is outside home-manager
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
}
