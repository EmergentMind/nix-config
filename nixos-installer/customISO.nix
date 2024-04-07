{ pkgs, lib, config, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # override installation-cd-base and enable wpa and sshd start at boot
  systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  isoImage.isoName = "${hostname}"
    #formatAttr = "isoImage";
    #fileExtension = ".iso";

    nixpkgs.hostPlatform = "x86_64-linux";

  users.users.nixos = {
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
