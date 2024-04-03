{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.password = "root";
  users.users.root.openssh.authorizedKeys.keys = [
    # Change these to your own ssh key(s)
    # Each key entered below should be one of the following:
    #  * a reference to a key file saved in the config. e.g. (builtins.readFile path/to/key.pub)
    #  * a string of the key.pub contents. e.g. "key_type yourpubkey key_id"

    # Add all keys for ease of access depending on where install is occurring.
    (builtins.readFile ../hosts/common/users/ta/keys/id_maya.pub)
    (builtins.readFile ../hosts/common/users/ta/keys/id_mara.pub)
    (builtins.readFile ../hosts/common/users/ta/keys/id_manu.pub)
    (builtins.readFile ../hosts/common/users/ta/keys/id_meek.pub)
  ];

  # Need 23.05 image until nixos-anywhere switches away from using rsync https://github.com/nix-community/nixos-anywhere/pull/295/files
  system.stateVersion = "23.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
