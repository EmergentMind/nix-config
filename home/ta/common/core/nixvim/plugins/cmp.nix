{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.cmp.enable = lib.mkEnableOption "enables cmp module";
  };

  config = lib.mkIf config.nixvim-config.plugins.cmp.enable {
    programs.nixvim.plugins = {
      nvim-cmp = {
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
               	if cmp.visible() then
              		cmp.select_next_item()
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
              	if cmp.visible() then
              		cmp.select_prev_item()
              	elseif luasnip.jumpable(-1) then
              		luasnip.jump(-1)
              	else
              		fallback()
              	end
              end
            '';
          };
          "<C-j>" = {
            action = "cmp.mapping.select_next_item()";
          };
          "<C-k>" = {
            action = "cmp.mapping.select_prev_item()";
          };
          "<C-e>" = {
            action = "cmp.mapping.abort()";
          };
          "<C-b>" = {
            action = "cmp.mapping.scroll_docs(-4)";
          };
          "<C-f>" = {
            action = "cmp.mapping.scroll_docs(4)";
          };
          "<C-Space>" = {
            action = "cmp.mapping.complete()";
          };
          "<CR>" = {
            action = "cmp.mapping.confirm({ select = true })";
          };
          "<S-CR>" = {
            action = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          };
        };
        cmp-nvim-lsp = {
          enable = true;
        }; # lsp
        cmp-buffer = {
          enable = true;
        };
        copilot-cmp = {
          enable = true;
        }; # copilot suggestions
        cmp-path = {
          enable = true;
        }; # file system paths
        cmp_luasnip = {
          enable = true;
        }; # snippets
        cmp-cmdline = {
          enable = false;
        }; # autocomplete for cmdline
      };
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

        local cmp = require'cmp'

          -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline({'/', "?" }, {
              sources = {
              { name = 'buffer' }
              }
              })

        -- Set configuration for specific filetype.
          cmp.setup.filetype('gitcommit', {
              sources = cmp.config.sources({
                  { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
                  }, {
                  { name = 'buffer' },
                  })
              })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline(':', {
              sources = cmp.config.sources({
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
