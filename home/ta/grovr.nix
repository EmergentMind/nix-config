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
          "extrabrowsers/brave.nix" # for testing against 'clara' user
          "helper-scripts"

          "atuin.nix"
          "sops.nix"
          "introdus-xdg.nix" # file associations
        ])
    )
  );

  introdus.services.yubikey-touch-detector = {
    enable = true;
    notificationSound = true;
  };
  system.ssh-motd = {
    enable = true;
    banner = "${inputs.nix-assets}/images/banners/grovr.png";
  };
}
