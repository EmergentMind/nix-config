{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.undotree.enable = lib.mkEnableOption "enables undotree module";
  };

  config = lib.mkIf config.nixvim-config.plugins.undotree.enable {
    programs.nixvim = {
      plugins = {
        undotree = {
          enable = true;

        };
      };
      keymaps = [
        {
          mode = [ "n" ];
          key = "<Leader>u";
          action = ":UndotreeToggle<cr>";
          options = {
            desc = "Toggle undotree"; # see undotree plugin
            noremap = true;
          };
        }

      ];
    };
  };
}
