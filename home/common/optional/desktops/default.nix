{ pkgs, ... }:
{
  imports = [
    # Packages with custom configs go here
    # ./gnome # don't enable through default anymore
    ./niri

    ########## Shell ##########
    ./noctalia

    ########## Utilities ##########
    ./services/kanshi.nix # Monitor profiles
  ];
  home.packages = [
    # FIXME: is the pulse stuff redundant?
    pkgs.pulseaudio # add pulse audio to the user path
    pkgs.pavucontrol # gui for pulseaudio server and volume controls
    pkgs.wl-clipboard # wayland copy and paste
    pkgs.galculator # gtk based calculator
  ];
}
