{ inputs, lib, ... }:
{
  imports = (
    map lib.custom.relativeToRoot (
      [
        # ========== Required modules ==========
        "home/common/core"
        "home/ta/common"
      ]
      ++
        # ========== Optional modules ==========
        (map (f: "home/common/optional/${f}") [
          "comms"
          "desktops" # default is niri
          "development"
          "extrabrowsers"
          # "gaming"
          "helper-scripts"
          "tools"
          "zellij"

          "atuin.nix"
          "authenticator.nix"
          "media.nix"
          "introdus-xdg.nix" # file associations
          "sops.nix"
          "yazi.nix"
        ])
    )
  );

  # introdus.services.awww = {
  #   enable = true;
  # wallpaperDir = "/home/ta/sync/wallpaper/hostCollections/genoa/";
  # };

  introdus.services.yubikey-touch-detector = {
    enable = true;
    notificationSound = true;
  };

  system.ssh-motd = {
    enable = true;
    banner = "${inputs.nix-assets}/images/banners/genoa.png";
  };

}
