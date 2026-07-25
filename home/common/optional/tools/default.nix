{ lib, pkgs, ... }:
{
  home.packages = lib.attrValues {
    inherit (pkgs)
      # Development
      tokei

      # Device imaging
      #rpi-imager
      #etcher #was disabled in nixpkgs due to dependency on insecure version of Electron

      #image viewers
      feh

      # Productivity
      drawio
      libreoffice

      # Web sites
      zola

      # Media production
      audacity
      gimp
      inkscape
      # VM and RDP
      # remmina
      ;

    inherit (pkgs.unstable)
      obs-studio
      ;
    inherit (pkgs.unstable.pkgsRocm)
      blender
      ;
  };
}
