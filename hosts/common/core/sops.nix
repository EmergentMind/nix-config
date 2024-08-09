# hosts level sops. see home/[user]/common/optional/sops.nix for home/user level

{
  pkgs,
  inputs,
  config,
  configVars,
  ...
}:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/secrets.yaml";

  # FIXME: Switch to a configLib function
  # this is some stuff for distinguishing linux from darwin. Likely just remove it.
  homeDirectory =
    if pkgs.stdenv.isLinux then "/home/${configVars.username}" else "/Users/${configVars.username}";
in
#homeDirectory = "/home/${configVars.username}";
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    # secrets will be output to /run/secrets
    # e.g. /run/secrets/msmtp-password
    # secrets required for user creation are handled in respective ./users/<username>.nix files
    # because they will be output to /run/secrets-for-users and only when the user is assigned to a host.
    secrets = {
      # For home-manager a separate age key is used to decrypt secrets and must be placed onto the host. This is because
      # the user doesn't have read permission for the ssh service private key. However, we can bootstrap the age key from
      # the secrets decrypted by the host key, which allows home-manager secrets to work without manually copying over
      # the age key.
      # These age keys are are unique for the user on each host and are generated on their own (i.e. they are not derived
      # from an ssh key).
      "user_age_keys/${configVars.username}_${config.networking.hostName}" = {
        owner = config.users.users.${configVars.username}.name;
        inherit (config.users.users.${configVars.username}) group;
        # We need to ensure the entire directory structure is that of the user...
        path = "${homeDirectory}/.config/sops/age/keys.txt";
      };

      # extract username/password to /run/secrets-for-users/ so it can be used to create the user
      "${configVars.username}/password".neededForUsers = true;

      #FIXME move to mstmp.nix and also have host and address being assigned to configVars as per fidgetingbits
      msmtp-host = { };
      msmtp-address = { };
      msmtp-password = { };

      # extract to default pam-u2f authfile location for passwordless sudo. see ../optional/yubikey
      "yubico/u2f_keys" = {
        path = "/home/${configVars.username}/.config/Yubico/u2f_keys";
      };
    };
  };
  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # FIXME: We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnwership =
    let
      ageFolder = "${homeDirectory}/.config/sops/age";
      user = config.users.users.${configVars.username}.name;
      group = config.users.users.${configVars.username}.group;
    in
    ''
      mkdir -p ${ageFolder} || true
      chown -R ${user}:${group} ${homeDirectory}/.config
    '';
}
