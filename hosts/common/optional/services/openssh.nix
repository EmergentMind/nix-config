{
  lib,
  config,
  configVars,
  ...
}:
let
  sshPort = configVars.networking.sshPort;

  # Sops needs access to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
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
    # Fix LPE vulnerability with sudo use SSH_AUTH_SOCK: https://github.com/NixOS/nixpkgs/issues/31611
    authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  };
  # yubikey login / sudo
  # this potentially causes a security issue that we mitigated above
  security.pam = {
    sshAgentAuth.enable = true;
    services = {
      sudo.u2fAuth = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ sshPort ];
}
