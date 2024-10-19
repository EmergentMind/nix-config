#
# Basic user for viewing media on gusto
#

{
  pkgs,
  config,
  configLib,
  ...
}:
let
  # FIXME make use of configVars for media user
  secretsSubPath = "passwords/media";
in
{
  # Decrypt passwords/media to /run/secrets-for-users/ so it can be used to create the user
  sops.secrets.${secretsSubPath}.neededForUsers = true;
  users.mutableUsers = false; # Required for password to be set via sops during system activation!

  users.users.media = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.${secretsSubPath}.path;
    shell = pkgs.zsh; # default shell
    extraGroups = [
      "audio"
      "video"
    ];

    packages = [ pkgs.home-manager ];
  };

  # Import this user's personal/home configurations
  home-manager.users.media = import (
    configLib.relativeToRoot "home/media/${config.networking.hostName}.nix"
  );
}
