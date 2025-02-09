#
# Basic user for viewing media on gusto
#

{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  #TODO(gusto): make use of hostSpec for media user
  hostSpec = config.hostSpec;
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
}
# Import this user's personal/home configurations
// lib.optionalAttrs (inputs ? "home-manager") {
  home-manager = {
    extraSpecialArgs = {
      inherit pkgs inputs;
      hostSpec = config.hostSpec;
    };
    users.media.imports = lib.flatten (
      lib.optional (!hostSpec.isMinimal) [
        (
          { config, ... }:
          import (lib.custom.relativeToRoot "home/media/${hostSpec.hostName}.nix") {
            inherit
              pkgs
              inputs
              config
              lib
              hostSpec
              ;
          }
        )
      ]
    );
  };
}
