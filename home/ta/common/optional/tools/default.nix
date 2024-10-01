{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)

      #remmina
      # edc

      # Productivity
      grimblast
      drawio
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
  #Disabled for now. grimblast
  #  services.flameshot = {
  #      enable = true;
  #     package = flameshotGrim;
  #  };
}
