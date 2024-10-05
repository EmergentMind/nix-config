# https://github.com/nvim-telescope/telescope.nvim
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.telescope.enable = lib.mkEnableOption "enables telescope module";
  };

  config = lib.mkIf config.nixvim-config.plugins.telescope.enable {
    programs.nixvim = {
      plugins.telescope = {
        enable = true;
        extensions.fzy-native.enable = true;
      };
      keymaps = [
        {
          mode = [ "n" ];
          key = "<Leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options = {
            desc = "find files";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<Leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options = {
            desc = "live grep";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<Leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options = {
            desc = "buffers";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<Leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
          options = {
            desc = "help tags";
            noremap = true;
          };
        }
      ];
    };
  };
}
