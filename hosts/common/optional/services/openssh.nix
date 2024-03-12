{ outputs, lib, config, ... }:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../../${host}/ssh_host_ed25519_key.pub;

  # Sops needs access to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  # hasOptinPersistence = config.environment.persistence ? "/persist";
  hasOptinPersistence = false;
in

{
  services.openssh = {
    enable = true;
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
  networking.firewall.allowedTCPPorts = [ 10022 ];

  # TODO: Re-enable host keys maybe
  # programs.ssh = {
  #   # Each hosts public key
  #   knownHosts = builtins.mapAttrs
  #     (name: _: {
  #       publicKeyFile = pubKey name;
  #       extraHostNames =
  #         (lib.optional (name == hostName) "localhost") ++ # Alias for localhost if it's the same host
  #         (lib.optionals (name == gitHost) [ "m7.rs" "git.m7.rs" ]); # Alias for m7.rs and git.m7.rs if it's the git host
  #     })
  #     hosts;
  # };

  # Passwordless sudo when SSH'ing with keys
  # NOTE: Hello future self! When you enabled this you ran into errors, and turned it off.
  # See: https://unix.stackexchange.com/questions/626143/sign-and-send-pubkey-signing-failed-for-rsa-key-from-agent-agent-refused-oper
  # security.pam.enableSSHAgentAuth = true;
}
