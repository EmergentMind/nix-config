{ modulesPath, config, lib, pkgs, configLib, ... }:
let
  pubKeys = lib.filesystem.listFilesRecursive (configLib.relativeToRoot "keys/");
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.virtualbox.guest.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  #FIXME this gets worse with every additional yubikey. eventually overhaul this config to leverage existing user configs similar to fidgetingbits
  programs.ssh.extraConfig = "Host gitlab.com\n  IdentitiesOnly yes\n  IdentityFile ~/.ssh/id_manu\n  IdentityFile ~/.ssh/id_mara\n  IdentityFile ~/.ssh/id_maya\n  IdentityFile ~/.ssh/id_meek\n  IdentityFile ~/.ssh/id_mila";

   # ssh-agent is used to pull my private secrets repo from gitlab when deploying nix-config.
  programs.ssh.startAgent = true;

  environment.systemPackages = builtins.attrValues {
    inherit(pkgs)
    wget
    curl
    rsync
    gitMinimal;
  };

  users.users.root = {
    password = "nixos";

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
