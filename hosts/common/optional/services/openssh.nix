{ lib, config, ... }:
let
  sshPort = 10022;

  # Sops needs access to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  # hasOptinPersistence = config.environment.persistence ? "/persist";
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

    hostKeys = [{
      path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };
  networking.firewall.allowedTCPPorts = [ sshPort ];

  # Passwordless sudo when SSH'ing with keys
  # NOTE: Hello future self! When you enabled this you ran into errors, and turned it off.
  # See: https://unix.stackexchange.com/questions/626143/sign-and-send-pubkey-signing-failed-for-rsa-key-from-agent-agent-refused-oper
  # security.pam.enableSSHAgentAuth = true;
}
