{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.fugitive.enable = lib.mkEnableOption "enables fugitive module";
  };

  config = lib.mkIf config.nixvim-config.plugins.fugitive.enable {
    programs.nixvim = {
      plugins.fugitive = {
        enable = true;
      };
      keymaps = [
        {
          mode = [ "n" ];
          key = "<Leader>gs";
          action = "<cmd>G<CR>";
          options = {
            desc = "quick git status";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<Leader>gj";
          action = "<cmd>diffget //3<CR>";
          options = {
            desc = "quick merge command: take from right page (tab 3) upstream";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<Leader>gf";
          action = "<cmd>diffget //2<CR>";
          options = {
            desc = "quick merge command: take from left page (tab 2) head";
            noremap = true;
          };
        }
      ];
    };
  };
}
