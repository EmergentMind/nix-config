{ pkgs, inputs, config, ... }:
let 
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Decrypt ta-password to /run/secrets-for-users/ so it can be used to create the user
  sops.secrets.ta-password.neededForUsers = true;
  users.mutableUsers = false; # Required for password to be set via sops during system activation!

  users.users.ta = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.ta-password.path;
    shell = pkgs.zsh; #default shell
    extraGroups = [
      "wheel"
      "audio"
      "video"
    ] ++ ifTheyExist [
      "docker"
      "git"
      "mysql"
      "network"
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./keys/id_maya.pub)
      (builtins.readFile ./keys/id_mara.pub)
      (builtins.readFile ./keys/id_manu.pub)
      (builtins.readFile ./keys/id_meek.pub)
    ];

    packages = [ pkgs.home-manager ];
  };

# FIXME This should probably be host specific. Also need to confirm that this is the correct place to do this.
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=120 # only ask for password every 120 minutes
  '';

  # Import this user's personal/home configurations
  home-manager.users.ta = import ../../../../home/ta/${config.networking.hostName}.nix;

}
