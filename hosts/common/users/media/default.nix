#
# Basic user for viewing media on gusto
#

{ pkgs, inputs, config, ... }:
{
  # Decrypt media-password to /run/secrets-for-users/ so it can be used to create the user
  sops.secrets.media-password.neededForUsers = true;
  users.mutableUsers = false; #Required for password to be set via sops during system activation!

  users.users.media = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.media-password.path;
    shell = pkgs.zsh; #default shell
    extraGroups = [
      "audio"
      "video"
    ];

    packages = [ pkgs.home-manager ];
  };

  # Import this user's personal/home configurations
  home-manager.users.media = import ../../../../home/media/${config.networking.hostName}.nix;

}
