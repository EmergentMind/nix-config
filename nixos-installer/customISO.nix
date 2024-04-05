{ pkgs, lib, config, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.ta = {
    isNormalUser = true;
    password = "temp";
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../hosts/common/users/ta/keys/id_meek.pub)
    ];
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      rsync;
  };

  #nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
