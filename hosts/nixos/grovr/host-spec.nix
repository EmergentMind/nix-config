{ inputs, lib, ... }:
{
  hostSpec = {
    hostName = "grovr";
    users = lib.mkForce [
      "ta"
      "clara"
    ];
    primaryUsername = lib.mkForce "ta";
    primaryDesktopUsername = lib.mkForce "clara";

    isImpermanent = lib.mkForce true;
    persistFolder = lib.mkForce "/persist";

    # System type flags
    isWork = lib.mkForce false;
    isProduction = lib.mkForce true;
    isRemote = lib.mkForce true;

    # Functionality
    useYubikey = lib.mkForce true;

    # Graphical
    defaultDesktop = "gnome";
    useWayland = lib.mkForce true;
    isAutoStyled = lib.mkForce true;
    theme = lib.mkForce "seafoam-pastel";
    wallpaper = "${inputs.nix-assets}/images/wallpapers/deco/ad-01.jpg";
  };
}
