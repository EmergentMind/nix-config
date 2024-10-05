# autopairs for neovim written in lua
# https://github.com/windwp/nvim-autopairs/
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.nvim-autopairs.enable = lib.mkEnableOption "enables nvim-autopairs module";
  };

  config = lib.mkIf config.nixvim-config.plugins.nvim-autopairs.enable {
    programs.nixvim.plugins = {
      nvim-autopairs = {
        enable = true;
        settings = {
          fast_wrap = { };
          disable_filetype = [
            "TelescopePrompt"
            "vim"
          ];
        };
      };
      extraConfigLua = # lua
        ''
          local npairs = require("nvim-autopairs")
          local Rule = require("nvim-autopairs.rule")

          npairs.add_rule(Rule("$$", "$$", "tex"))

        '';
    };
  };
}
