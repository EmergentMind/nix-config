# Preview md in browser
# https://github.com/iamcco/markdown-preview.nvim
# nixvim docs:
# https://nix-community.github.io/nixvim/stable/plugins/markdown-preview/index.html?highlight=markdown#markdown-preview
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.markdown-preview.enable = lib.mkEnableOption "enables markdown-preview module";
  };

  config = lib.mkIf config.nixvim-config.plugins.markdown-preview.enable {
    programs.nixvim = {
      plugins.markdown-preview = {
        enable = true;
        settings = {
          browser = "firefox";
          theme = "dark";
        };
      };
      keymaps = [
        {
          mode = "n";
          key = "<leader>cp";
          action = "<cmd>MarkdownPreview<cr>";
          options = {
            desc = "Markdown Preview";
          };
        }
      ];
    };
  };
}
