{
  pkgs,
  lib,
  configVars,
  ...
}:
let
  sshPort = configVars.networking.ports.tcp.ssh;

  # Sops needs access to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  #FIXME-impermanence refactor this to how fb did it
  hasOptinPersistence = false;
in

{
  services.openssh = {
    enable = true;
    ports = [ sshPort ];

    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };

    hostKeys = [
      {
        path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # yubikey login / sudo
  # NOTE: We use rssh because sshAgentAuth is old and doesn't support yubikey:
  # https://github.com/jbeverly/pam_ssh_agent_auth/issues/23
  # https://github.com/z4yx/pam_rssh
  security.pam.services.sudo =
    { config, ... }:
    {
      rules.auth.rssh = {
        order = config.rules.auth.ssh_agent_auth.order - 1;
        control = "sufficient";
        modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
        settings.authorized_keys_command = pkgs.writeShellScript "get-authorized-keys" ''
          cat "/etc/ssh/authorized_keys.d/$1"
        '';
      };
    };

  networking.firewall.allowedTCPPorts = [ sshPort ];
}
