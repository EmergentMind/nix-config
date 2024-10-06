# keybind helper
# https://github.com/folke/which-key.nvim
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.which-key.enable = lib.mkEnableOption "enables which-key module";
  };

  config = lib.mkIf config.nixvim-config.plugins.which-key.enable {
    programs.nixvim = {
      plugins.which-key = {
        enable = true;
      };
      opts = {
        timeout = true;
        timeoutlen = 300;
      };
    };
  };
}
