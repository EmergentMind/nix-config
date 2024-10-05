{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.cmp.enable = lib.mkEnableOption "enables cmp and lspkind modules";
  };

  config = lib.mkIf config.nixvim-config.plugins.cmp.enable {
    programs.nixvim.plugins = {
      lspkind.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          window = {
            completion = {
              border = "rounded";
              scrollbar = false;
            };
            documentation = {
              border = "rounded";
            };
            snippet.expand = # lua
              ''
                function(args)
                  require("luasnip").lsp_expand(args.body)
                end
              '';
          };
          sources = [
            { name = "cmp-nvim-lsp"; }
            { name = "async_path"; }
            { name = "nvim_lsp_signature_help"; }
            {
              name = "nvim_lsp";
              keyword_length = 3;
            }
            {
              name = "nvim_lua";
              keyword_length = 2;
            }
            { name = "luasnip"; }
            {
              name = "buffer";
              keyword_length = 2;
            }
          ];
          mapping = {
            __raw = # lua
              ''
                cmp.mapping.preset.insert({
                  ["<C-k>"] = cmp.mapping.select_prev_item(),
                  ["<C-j>"] = cmp.mapping.select_next_item(),

                  ["<c-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
                  ["<c-d>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),

                  ["<C-e>"] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close(),
                  }),

                  -- Making Ctrl-Enter accept the top entry instead of Enter
                  ["<c-CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                  }),
                  ["<CR>"] = cmp.mapping({
                    i = function(fallback)
                      fallback()
                    end,
                  }),

                  ["<c-h>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif require("luasnip").jumpable(-1) then
                      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
                  ["<c-l>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif require("luasnip").expand_or_jumpable() then
                      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                    else
                      fallback()
                    end
                  end, { "i", "s" }),

                  ["<c-space>"] = cmp.mapping(function(fallback)

                  local copk, _ = pcall(require, "copilot")

                  if copk then
                    vim.g.copilot_no_tab_map = true
                    vim.g.copilot_assume_mapped = true
                    vim.g.copilot_tab_fallback = ""
                    local suggestion = require("copilot.suggestion")
                    if suggestion.is_visible() then
                      suggestion.accept()
                    elseif cmp.visible() then
                      cmp.select_next_item()
                    elseif require("luasnip").expand_or_jumpable() then
                      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                    else
                      fallback()
                    end
                  else
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif require("luasnip").expand_or_jumpable() then
                      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                    else
                      fallback()
                    end
                  end
                  end, { "i", "s" })
                 })
              '';
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lua.enable = true;
      cmp-buffer.enable = true;
      cmp-async-path.enable = true;
      cmp-cmdline.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;

      luasnip = {
        enable = true;
      };
      extraConfigLua = # lua
        ''
          local ok, lspkind = pcall(require, "lspkind")
          if ok then
            -- setting highlights for
            vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
            vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
            vim.api.nvim_set_hl(0, "CmpItemKindCrate", { fg = "#F64D00" })
            vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })

            require("cmp").setup({

              formatting = {
                format = lspkind.cmp_format({
                  maxwidth = 80,
                  ellipsis_char = "...",
                  show_labelDetails = true,
                  before = function(entry, vim_item)
                    if entry.source.name == "copilot" then
                      vim_item.kind = icons.kind.Copilot
                      vim_item.kind_hl_group = "CmpItemKindCopilot"
                    end

                    if entry.source.name == "cmp_tabnine" then
                      vim_item.kind = icons.kind.TabNine
                      vim_item.kind_hl_group = "CmpItemKindTabnine"
                    end

                    if entry.source.name == "crates" then
                      vim_item.kind = icons.misc.Package
                      vim_item.kind_hl_group = "CmpItemKindCrate"
                    end

                    if entry.source.name == "lab.quick_data" then
                      vim_item.kind = icons.misc.CircuitBoard
                      vim_item.kind_hl_group = "CmpItemKindConstant"
                    end

                    if entry.source.name == "emoji" then
                      vim_item.kind = icons.misc.Smiley
                      vim_item.kind_hl_group = "CmpItemKindEmoji"
                    end
                    ---@diagnostic disable-next-line: redefined-local
                    local ok, tw = pcall(require, "tailwindcss-colorizer-cmp")
                    if ok then
                      vim_item = tw.formatter(entry, vim_item)
                    end

                    return vim_item
                  end,
                }),
                fields = { "abbr", "menu", "kind" }
              }
            })
          end
        '';
    };
  };
}
