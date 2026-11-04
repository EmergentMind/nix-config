{ config, lib, ... }:
let
  cfg = config.tunnels.cakes;
in
{
  options = {
    tunnels.cakes = {
      enable = lib.mkEnableOption "cakes tunnel";
      sopsEntry = lib.mkOption rec {
        type = lib.types.str;
        default = "keys/ssh/ed25519";
        example = default;
        description = "Yaml path in sops file that points to the ssh key";
      };

      sopsFile = lib.mkOption rec {
        type = lib.types.str;
        default = config.sops.defaultSopsFiles;
        example = default;
        description = "Path to the sops secrets file";
      };
      keyPath = lib.mkOption rec {
        type = lib.types.str;
        default = "/etc/ssh/id_ed25519";
        example = default;
        description = "Passwordless host key for tunnel creation via ssh";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      secrets = {
        "${cfg.sopsEntry}" = {
          inherit (cfg) sopsFile;

          owner = "autossh";
          group = "autossh";
          path = cfg.keyPath;
        };
        "${cfg.sopsEntry}_pub" = {
          inherit (cfg) sopsFile;

          owner = "autossh";
          group = "autossh";
          path = "${cfg.keyPath}.pub";
        };
      };
    };
    services.autosshTunnels.sessions = {
      freshcakes = {
        user = "tunnel";
        host = config.hostSpec.networking.hosts.freshcakes;
        port = 22;
        secretKey = cfg.keyPath;
        tunnels = [
          {
            localPort = config.hostSpec.networking.ports.tcp.jellyfin;
            remotePort = config.hostSpec.networking.ports.tcp.jellyfin;
          }
        ];
      };
    };
  };
}
