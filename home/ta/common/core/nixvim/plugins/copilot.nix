{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.copilot.enable = lib.mkEnableOption "enables copilot module";
  };

  config = lib.mkIf config.nixvim-config.plugins.copilot.enable {
    programs.nixvim.plugins = {
      copilot = {
        enable = true;
        autoEnableSources = true;
        experimental = {
          ghost_text = true;
        };
        performance = {
          debounce = 60;
          fetchingTimeout = 200;
          maxViewEntries = 30;
        };
        snippet = {
          expand = "luasnip";
        };
        formatting = {
          fields = [
            "kind"
            "abbr"
            "menu"
          ];
        };
        sources = [
          {
            name = "nvim_lsp"; # lsp
          }
          {
            name = "buffer"; # text within current buffer
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            keywordLength = 3;
          }
          {
            name = "copilot"; # copilot suggestions
          }
          {
            name = "path"; # file system paths
            keywordLength = 3;
          }
          {
            name = "luasnip"; # snippets
            keywordLength = 3;
          }
        ];

        window = {
          completion = {
            border = "rounded";
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
          };
          documentation = {
            border = "rounded";
          };
        };

        mapping = {
          "<Tab>" = {
            modes = [
              "i"
              "s"
            ];
            action = ''
               function(fallback)
               	if copilot.visible() then
              		copilot.select_next_item()
              elseif luasnip.expand_or_jumpable() then
              	luasnip.expand_or_jump()
              else
              fallback()
                   end
              end
            '';
          };
          "<S-Tab>" = {
            modes = [
              "i"
              "s"
            ];
            action = ''
                   function(fallback)
              	if copilot.visible() then
              		copilot.select_prev_item()
              	elseif luasnip.jumpable(-1) then
              		luasnip.jump(-1)
              	else
              		fallback()
              	end
              end
            '';
          };
          "<C-j>" = {
            action = "copilot.mapping.select_next_item()";
          };
          "<C-k>" = {
            action = "copilot.mapping.select_prev_item()";
          };
          "<C-e>" = {
            action = "copilot.mapping.abort()";
          };
          "<C-b>" = {
            action = "copilot.mapping.scroll_docs(-4)";
          };
          "<C-f>" = {
            action = "copilot.mapping.scroll_docs(4)";
          };
          "<C-Space>" = {
            action = "copilot.mapping.complete()";
          };
          "<CR>" = {
            action = "copilot.mapping.confirm({ select = true })";
          };
          "<S-CR>" = {
            action = "copilot.mapping.confirm({ behavior = copilot.ConfirmBehavior.Replace, select = true })";
          };
        };
      };
      copilot-nvim-lsp = {
        enable = true;
      }; # lsp
      copilot-buffer = {
        enable = true;
      };
      copilot-copilot = {
        enable = true;
      }; # copilot suggestions
      copilot-path = {
        enable = true;
      }; # file system paths
      copilot_luasnip = {
        enable = true;
      }; # snippets
      copilot-cmdline = {
        enable = false;
      }; # autocomplete for cmdline
      extraConfigLua = ''
          luasnip = require("luasnip")
          kind_icons = {
            Text = "󰊄",
            Method = "",
            Function = "󰡱",
            Constructor = "",
            Field = "",
            Variable = "󱀍",
            Class = "",
            Interface = "",
            Module = "󰕳",
            Property = "",
            Unit = "",
            Value = "",
            Enum = "",
            Keyword = "",
            Snippet = "",
            Color = "",
            File = "",
            Reference = "",
            Folder = "",
            EnumMember = "",
            Constant = "",
            Struct = "",
            Event = "",
            Operator = "",
            TypeParameter = "",
          }

        local copilot = require'copilot'

          -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
          copilot.setup.cmdline({'/', "?" }, {
              sources = {
              { name = 'buffer' }
              }
              })

        -- Set configuration for specific filetype.
          copilot.setup.filetype('gitcommit', {
              sources = copilot.config.sources({
                  { name = 'copilot_git' }, -- You can specify the `copilot_git` source if you were installed it.
                  }, {
                  { name = 'buffer' },
                  })
              })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
          copilot.setup.cmdline(':', {
              sources = copilot.config.sources({
                  { name = 'path' }
                  }, {
                  { name = 'cmdline' }
                  }),
              --      formatting = {
              --       format = function(_, vim_item)
              --         vim_item.kind = cmdIcons[vim_item.kind] or "FOO"
              --       return vim_item
              --      end
              -- }
              })  '';
    };
  };
}
