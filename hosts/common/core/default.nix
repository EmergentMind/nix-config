{
  pkgs,
  lib,
  inputs,
  outputs,
  configLib,
  configVars,
  ...
}:
let

  #FIXME:(configLib) switch this and other instances to configLib function
  homeDirectory =
    if pkgs.stdenv.isLinux then "/home/${configVars.username}" else "/Users/${configVars.username}";
in
{
  imports = lib.flatten [
    (configLib.scanPaths ./.)
    (configLib.relativeToRoot "hosts/common/users/${configVars.username}")
    inputs.home-manager.nixosModules.home-manager
    (builtins.attrValues outputs.nixosModules)
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 20";
    flake = "${homeDirectory}/nix-config";
  };

  configOptions.silencedWarnings = [
    # see https://github.com/NixOS/nixpkgs/pull/287506 for more information
    "The user '${configVars.username}' has multiple of the options\n`hashedPassword`, `password`, `hashedPasswordFile`, `initialPassword`\n& `initialHashedPassword` set to a non-null value.\nThe options silently discard others by the order of precedence\ngiven above which can lead to surprising results. To resolve this warning,\nset at most one of the options above to a non-`null` value.\n\nThe values of these options are:\n* users.users.\"${configVars.username}\".hashedPassword: null\n* users.users.\"${configVars.username}\".hashedPasswordFile: \"/run/secrets-for-users/${configVars.username}/password\"\n* users.users.\"${configVars.username}\".password: \"nixos\"\n"
    "The user 'root' has multiple of the options\n`hashedPassword`, `password`, `hashedPasswordFile`, `initialPassword`\n& `initialHashedPassword` set to a non-null value.\nThe options silently discard others by the order of precedence\ngiven above which can lead to surprising results. To resolve this warning,\nset at most one of the options above to a non-`null` value.\n\nThe values of these options are:\n* users.users.\"root\".hashedPassword: null\n* users.users.\"root\".hashedPasswordFile: \"/run/secrets-for-users/${configVars.username}/password\"\n* users.users.\"root\".password: \"nixos\"\n"
  ];

  # This should be handled by config.security.pam.sshAgentAuth.enable
  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
    # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    # you can add global overlays here
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  hardware.enableRedistributableFirmware = true;
}
