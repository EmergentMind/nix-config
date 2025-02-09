{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.bufferline.enable = lib.mkEnableOption "enables bufferline module";
  };

  config = lib.mkIf config.nixvim-config.plugins.bufferline.enable {
    programs.nixvim.plugins = {
      bufferline = {
        enable = true;
        settings = {
          options = {
            separatorStyle = "slant"; # “slant”, “padded_slant”, “slope”, “padded_slope”, “thick”, “thin”
            offsets = [
              {
                filetype = "neo-tree";
                text = "Neo-tree";
                highlight = "Directory";
                text_align = "left";
              }
            ];
          };
        };
        # FIXME decide: move these to binds area or have plugin specific binds in the plugin module?
        #    keymaps = [
        #      {
        #        mode = "n";
        #        key = "<Tab>";
        #        action = "<cmd>BufferLineCycleNext<cr>";
        #        options = {
        #          desc = "Cycle to next buffer";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<S-Tab>";
        #        action = "<cmd>BufferLineCyclePrev<cr>";
        #        options = {
        #          desc = "Cycle to previous buffer";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<S-l>";
        #        action = "<cmd>BufferLineCycleNext<cr>";
        #        options = {
        #          desc = "Cycle to next buffer";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<S-h>";
        #        action = "<cmd>BufferLineCyclePrev<cr>";
        #        options = {
        #          desc = "Cycle to previous buffer";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>bd";
        #        action = "<cmd>bdelete<cr>";
        #        options = {
        #          desc = "Delete buffer";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>bb";
        #        action = "<cmd>e #<cr>";
        #        options = {
        #          desc = "Switch to Other Buffer";
        #        };
        #      }
        #
        #      # {
        #      #   mode = "n";
        #      #   key = "<leader>`";
        #      #   action = "<cmd>e #<cr>";
        #      #   options = {
        #      #     desc = "Switch to Other Buffer";
        #      #   };
        #      # }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>br";
        #        action = "<cmd>BufferLineCloseRight<cr>";
        #        options = {
        #          desc = "Delete buffers to the right";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>bl";
        #        action = "<cmd>BufferLineCloseLeft<cr>";
        #        options = {
        #          desc = "Delete buffers to the left";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>bo";
        #        action = "<cmd>BufferLineCloseOthers<cr>";
        #        options = {
        #          desc = "Delete other buffers";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>bp";
        #        action = "<cmd>BufferLineTogglePin<cr>";
        #        options = {
        #          desc = "Toggle pin";
        #        };
        #      }
        #
        #      {
        #        mode = "n";
        #        key = "<leader>bP";
        #        action = "<Cmd>BufferLineGroupClose ungrouped<CR>";
        #        options = {
        #          desc = "Delete non-pinned buffers";
        #        };
        #      }
        #    ];
        #  };

      };
    };
  };
}
