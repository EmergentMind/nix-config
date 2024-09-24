{ pkgs, ... }:
{
  imports = [
    # Packages with custom configs go here

    ./hyprland

    ########## Utilities ##########
    ./services/dunst.nix # Notification daemon
    ./waybar.nix # infobar
    #./fonts.nix
    #./playerctl.nix # cli util and lib for controlling media players that implement MPRIS
    #./gtk.nix # mainly in gnome
    #./qt.nix # mainly in kde
  ];
  home.packages = [
    pkgs.rofi-wayland # app launcher
    pkgs.pavucontrol # gui for pulseaudio server and volume controls
    pkgs.wl-clipboard # wayland copy and paste
  ];
}
