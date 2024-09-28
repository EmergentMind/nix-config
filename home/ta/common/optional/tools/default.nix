{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)

      #remmina
      # edc

      # Productivity
      drawio
      flameshot # depends on entry in nix-config/overlays/default.nix as well as 'grim' in hosts/common/optional/wayland.nix
      libreoffice

      # Privacy
      #veracrypt
      #keepassxc

      # device imaging
      rpi-imager
      #etcher #was disabled in nixpkgs due to depency on insecure version of Electron

      # media production
      audacity
      blender
      gimp
      inkscape
      obs-studio
      ;
  };
}
