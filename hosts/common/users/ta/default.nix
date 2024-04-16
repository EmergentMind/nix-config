{ pkgs, inputs, config, lib, configVars, configLib, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsHashedPasswordFile = lib.optionalString (lib.hasAttr "sops" inputs) config.sops.secrets."${configVars.username}/password".path;
in
{
  # Decrypt ta-password to /run/secrets-for-users/ so it can be used to create the user
  sops.secrets."${configVars.username}/password".neededForUsers = true;
  users.mutableUsers = false; # Required for password to be set via sops during system activation!

  users.users.${configVars.username} = {
    name = configVars.username;
    isNormalUser = true;
    hashedPasswordFile = sopsHashedPasswordFile;
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "audio"
      "video"
      "docker"
      "git"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./keys/id_maya.pub)
      (builtins.readFile ./keys/id_mara.pub)
      (builtins.readFile ./keys/id_manu.pub)
    ];

    shell = pkgs.zsh; # default shell

    packages = [ pkgs.home-manager ];
  };

  # Import this user's personal/home configurations
  home-manager.users.${configVars.username} = import (configLib.relativeToRoot "home/${configVars.username}/${config.networking.hostName}.nix");

}
