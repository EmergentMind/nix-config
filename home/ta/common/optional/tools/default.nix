{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
    
    #remmina
    # edc
    flameshot ?? maybe somewhere else

    # Productivity
    libreoffice
    drawio
    drawio-export-all

    # Privacy
    #veracrypt
    #keepassxc
    
    # imaging
    wally-cli #mechanical keeb firmware flasher
    rpi-imager
    etcher

    # media production
    audacity
    blender
    gimp
    inkscape
    obs-studio
    
    ;
  };
}

