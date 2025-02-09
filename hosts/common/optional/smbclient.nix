# create a systemd service to automatically mount the ghost mediashare at boot
{ inputs, pkgs, ... }:
let
  sopsFolder = (builtins.toString inputs.nix-secrets) + "/sops";
in
{
  # required to mount cifs using domain name
  environment.systemPackages = [ pkgs.cifs-utils ];

  # setup the required secrets
  sops.secrets = {
    "smb-secrets" = {
      sopsFile = "${sopsFolder}/shared.yaml";
      path = "/etc/nixos/smb-secrets";
    };
  };

  fileSystems."/mnt/mediashare" = {
    device = "//ghost/mediashare";
    fsType = "cifs";
    options =
      let
        # separate options to prevent hanging on network split
        # 'noauto'= do not mount via fstab. Will be automounted by systemd
        separate_options = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${separate_options},credentials=/etc/nixos/smb-secrets" ];
  };
}
