{ pkgs, inputs, config, lib, configVars, configLib, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsHashedPasswordFile = lib.optionalString (lib.hasAttr "sops" inputs) config.sops.secrets."${configVars.primaryUser}/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (./keys);
in
{

  # isMinimal is true during nixos-installer boostrapping (see /nixos-installer/flake.nix) where we want
  # to limit the depth of user configuration
  # FIXME  this should just pass an isIso style thing that we can check instead
  config = lib.optionalAttrs (!(lib.hasAttr "isMinimal" configVars))
  {
    # Import this user's personal/home configurations
#??     packages = [ pkgs.home-manager ];
    home-manager.users.${configVars.primaryUser} = import (configLib.relativeToRoot "home/${configVars.primaryUser}/${config.networking.hostName}.nix");
  } // {
    # Decrypt ta-password to /run/secrets-for-users/ so it can be used to create the user
    sops.secrets."${configVars.primaryUser}/password".neededForUsers = true;

    users.mutableUsers = false; # Required for password to be set via sops during system activation!
    users.users.${configVars.primaryUser} = {
      isNormalUser = true;
      hashedPasswordFile = sopsHashedPasswordFile;
      password = "nixos"; # This gets overridden if sops is working

      extraGroups = [
        "wheel"
      ] ++ ifTheyExist [
        "audio"
        "video"
        "docker"
        "git"
        "networkmanager"
      ];

      # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
      openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

      shell = pkgs.zsh; # default shell

    };

    # Proper root use required for borg and some other specific operations
    users.users.root = {
      hashedPasswordFile = config.users.users.${configVars.primaryUser}.hashedPasswordFile;
      password = lib.mkForce config.users.users.${configVars.primaryUser}.password;
      # root's ssh keys are mainly used for remote deployment.
      openssh.authorizedKeys.keys = config.users.users.${configVars.primaryUser}.openssh.authorizedKeys.keys;
    };

    # No matter what environment we are in we want these tools for root, and the user(s)
    programs.zsh.enable = true;
    programs.git.enable = true;
    environment.systemPackages = [
      pkgs.just
      pkgs.rsync
    ];
  };
}
