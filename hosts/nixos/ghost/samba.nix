#FIXME(structure): this needs a proper home but not sure where yet

# Once this service is started for the first time
# add any required users and passwords
# `sudo smbpasswd -a <user>` and follow prompts

{ pkgs, config, ... }:
let
  localPrefix = config.hostSpec.networking.subnets.grove.triplet;
in
{
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  services.samba = {
    enable = true;

    # `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
    # Required for samba to register mDNS records for auto discovery
    # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
    package = pkgs.samba4Full;
    openFirewall = true;
    settings = {
      # config settings https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
      global = {
        "invalid users" = [ "root" ];
        "workgroup" = "WORKGROUP";
        "security" = "user";
        "hosts allow" = "${localPrefix}. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "mediashare" = {
        "path" = "/mnt/extra/mediashare";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    publish.enable = true;
    publish.userServices = true;
    #FIXME: the following comment and option are from wiki.nixos.org example. confirm and fix
    # Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    nssmdns4 = true;
    enable = true;
    openFirewall = true;
  };
}
