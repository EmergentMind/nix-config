{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.lualine.enable = lib.mkEnableOption "enables lualine module";
  };

  config = lib.mkIf config.nixvim-config.plugins.lualine.enable {
    programs.nixvim.plugins.lualine = {
      enable = true;
      settings.options = {
        icons_enabled = true;
        #FIXME vim - determine if this is controlled elsewher... colorscheme, stylix, etc?
        #       theme = "dracula";
      };
    };
  };
}
