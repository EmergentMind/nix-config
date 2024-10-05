{
  lib,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.);

  #   config = lib.mkIf config.nixvim-config.enable {  # don't want to gif on options one level out of here yet
  config = {
    #TODO nixvim plugins to explore or setup still
    # todo-comments # maybe too fluff https://github.com/folke/todo-comments.nvim
    # hardtime # training tool to stop bad vim habits # https://github.com/m4xshen/hardtime.nvim
    # lint # not sure if this is redundant with all the other language stuff
    # conform # meant to make lsp less disruptive to the buffer #https://github.com/stevearc/conform.nvim
    # lspsaga # meant to improve the lsps experience for nvim #https://github.com/nvimdev/lspsaga.nvim
    # trouble # side or bottom list of all 'trouble' items in your code.#https://github.com/folke/trouble.nvim/
    # none-ls # inject LSP diagnostics, code actions, and more via LUA #https://github.com/nvimtools/none-ls.nvim
    # harpoon #file nav
    # ultimate-autopair #https://github.com/altermo/ultimate-autopair.nvim
    #    works with nvim-surround
    # nvim-surround #https://github.com/kylechui/nvim-surround
    # or tim popes surround
    # vim-grepper
    # better-escape #https://github.com/max397574/better-escape.nvim
    # toggle-term #https://github.com/akinsho/toggleterm.nvim

    # vim-polyglot # a collection of language packs for vim
    # # The following are already included in vim-polyglot
    # #but in case poly-glot fails I want to be able to quickly enable what I need.
    # haskell-vim
    # plantuml-syntax
    # pgsql-vim
    # python-syntax
    # rust-vim
    # vim-markdown
    # vim-nix
    # vim-terraform
    # vim-tomlolyglot # collection of language packs

    #
    # ========== ui ==========
    #
    nixvim-config.colorschemes.enable = lib.mkDefault true;
    nixvim-config.plugins.nvim-colorizer.enable = lib.mkDefault true;
    nixvim-config.plugins.alpha.enable = lib.mkDefault true;
    nixvim-config.plugins.dressing.enable = lib.mkDefault false;
    #
    # ========== bars/lines ==========
    #
    nixvim-config.plugins.bufferline.enable = lib.mkDefault false;
    nixvim-config.plugins.lualine.enable = lib.mkDefault true;
    #
    # ========== trees ==========
    #
    nixvim-config.plugins.neo-tree.enable = lib.mkDefault true;
    nixvim-config.plugins.undotree.enable = lib.mkDefault true;
    #
    # ========== git ==========
    #
    nixvim-config.plugins.neogit.enable = lib.mkDefault true;
    nixvim-config.plugins.fugitive.enable = lib.mkDefault true;
    #nixvim-config.plugins.lazygit.enable = lib.mkDefault false;
    #
    # ========== completion ==========
    #
    nixvim-config.plugins.cmp.enable = lib.mkDefault false;
    nixvim-config.plugins.copilot.enable = lib.mkDefault false;
    nixvim-config.plugins.nvim-autopairs.enable = lib.mkDefault false;
    #
    # ========== languages ==========
    #
    # nixvim-config.plugins.treesitter.enable = lib.mkDefault true;

    #
    # ========== lsp ==========
    #
    nixvim-config.plugins.fidget.enable = lib.mkDefault true;
    nixvim-config.plugins.lspconfig.enable = lib.mkDefault true;
    #
    # ========== search ==========
    #
    nixvim-config.plugins.telescope.enable = lib.mkDefault true;
    nixvim-config.plugins.wilder.enable = lib.mkDefault true;
    #
    # ========== sessions ==========
    #
    nixvim-config.plugins.auto-session.enable = lib.mkDefault true;
    #
    # ========== utils ==========
    #
    nixvim-config.plugins.markdown-preview.enable = lib.mkDefault true;
    nixvim-config.plugins.which-key.enable = lib.mkDefault true;
  };
}
