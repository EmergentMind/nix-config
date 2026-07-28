{ lib, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      #TODO(rice): set via stylix
      color_theme = lib.mkForce "gruvbox_dark";
      round_corners = true;
      theme_background = true;
      vim_keys = true;
      disks_filter = "exclude=/ /boot /persist";
    };
  };
}
