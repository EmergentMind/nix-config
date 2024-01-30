{
  imports = [
    # Packages with custom configs go here

# TODO this is just a pass through to hyprland atm. eventually if additional wms are add it will need to be refactored
# May want to consider a home/ta/common/desktops/common/ dir for configs shared across wms
    ./hyprland
#    ./gtk.nix # mainly in gnome
#    ./qt.nix # mainly in kde
#    ./fonts.nix
  ];
}