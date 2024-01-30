{config, pkgs, ...}:
{
  programs.hyprland = {
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland; # default

    # FIXME conditionally enable this based on host system
    #enableNvidiaPatches = true;

  };

  # Option, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

}