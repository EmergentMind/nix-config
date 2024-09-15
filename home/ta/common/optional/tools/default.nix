{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)

      #remmina
      # edc
      flameshot # ?? maybe somewhere else

      # Productivity
      libreoffice
      drawio

      # cryptocurrency
      # daedalus-mainnet #doubtful this is in home-manager

      # Privacy
      #veracrypt
      #keepassxc

      # imaging
      wally-cli # mechanical keeb firmware flasher
      rpi-imager
      #etcher #was disable in nixpkgs due to depency on insecure version of Electron

      # media production
      audacity
      blender
      gimp
      inkscape
      obs-studio

      ;
  };
}
