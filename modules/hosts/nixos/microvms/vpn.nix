# Sets up a wireguard connection to the given server and exposes an interface
# `vm-vpn`. See the

{
  pkgs,
  lib,
  config,
  inputs,
  namespace,
  ...
}:
let
  secretsFolder = lib.toString inputs.nix-secrets;
  sopsFolder = secretsFolder + "/sops/";
  cfg = config.${namespace}.microvms.vpn;
  vpn = config.hostSpec.networking.vpn.wg-proton-microvms;
in
{
  options.${namespace}.microvms.vpn = {
    enable = lib.mkEnableOption "Enable outgoing microvm VPN bridge";
    ifname = lib.mkOption {
      type = lib.types.str;
      default = "vm-vpn";
      example = "vm-vpn";
      description = "Name of interface used for microvms outbound traffic to route over VPN";
    };
    tableNum = lib.mkOption {
      type = lib.types.int;
      default = 42;
      example = 42;
      description = "Table number used for microvm VPN routing";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 51821;
      example = 51820;
      description = ''
        Wireguard port for proton vpn connection.
        IMPORTANT: Must not conflict with other wireguard listeners
      '';
    };
    privateKey = lib.mkOption {
      type = lib.types.str;
      default = "keys/wireguard/proton_sk";
      description = "Entry in sopsFile holding the secret key";
    };
    sopsFile = lib.mkOption {
      type = lib.types.str;
      default = "${sopsFolder}/microvms.yaml";
      description = "Sops file holding ProtonVPN secret key";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wireguard.interfaces.${cfg.ifname} = {
      ips = [ "10.2.0.2/32" ]; # NOTE: This is specified by proton, not optional
      allowedIPsAsRoutes = false;
      peers = [
        {
          allowedIPs = [
            "0.0.0.0/0"
          ];
          inherit (vpn) publicKey endpoint;
        }
      ];
      privateKeyFile = config.sops.secrets.${cfg.privateKey}.path;
      listenPort = cfg.port;
      postSetup = ''
        ${pkgs.iproute2}/bin/ip route add default dev ${cfg.ifname} table ${toString cfg.tableNum}
      '';
    };

    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = [ pkgs.wireguard-tools ];

    sops.secrets = {
      ${cfg.privateKey} = {
        sopsFile = cfg.sopsFile;
      };
    };
  };
}
