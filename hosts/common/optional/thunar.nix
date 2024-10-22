{ pkgs, ... }:
{
  programs = {
    thunar = {
      enable = true;
      plugins = builtins.attrValues {
        inherit (pkgs.xfce)
          thunar-archive-plugin
          thunar-media-tags-plugin
          thunar-volman
          ;
      };
    };
    xfconf.enable = true; # required to persist Thunar settings since we're not running on XFCE
    file-roller.enable = true; # required for Thunar archive plugin
  };
  services = {
    gvfs.enable = true; # for stuff like Trash folders etc
    udisks2.enable = true; # storage device manipulation
    tumbler.enable = true; # thumbnail generation service for Thunar
  };
}
