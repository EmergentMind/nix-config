{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.neo-tree.enable = lib.mkEnableOption "enables neo-tree module";
  };

  config = lib.mkIf config.nixvim-config.plugins.neo-tree.enable {
    programs.nixvim = {
      plugins.neo-tree = {
        enable = true;
        enableDiagnostics = true;
        enableGitStatus = true;
        enableModifiedMarkers = true;
        enableRefreshOnWrite = true;
        closeIfLastWindow = true;
        popupBorderStyle = "rounded"; # Type: null or one of “NC”, “double”, “none”, “rounded”, “shadow”, “single”, “solid” or raw lua code
        buffers = {
          bindToCwd = false;
          followCurrentFile = {
            enabled = true;
          };
        };
        window = {
          width = 40;
          height = 15;
          autoExpandWidth = false;
          mappings = {
            "<space>" = "none";
          };
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = ":Neotree toggle reveal_force_cwd<cr>";
          options = {
            silent = true;
            desc = "Explorer NeoTree (root dir)";
          };
        }
        {
          mode = "n";
          key = "<leader>E";
          action = "<cmd>Neotree toggle<CR>";
          options = {
            silent = true;
            desc = "Explorer NeoTree (cwd)";
          };
        }
        {
          mode = "n";
          key = "<leader>be";
          action = ":Neotree buffers<CR>";
          options = {
            silent = true;
            desc = "Buffer explorer";
          };
        }
        {
          mode = "n";
          key = "<leader>ge";
          action = ":Neotree git_status<CR>";
          options = {
            silent = true;
            desc = "Git explorer";
          };
        }
      ];
    };
  };
}
