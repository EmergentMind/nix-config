{
  config,
  lib,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.);

  #   config = lib.mkIf config.nixvim-config.enable {  # don't want to gif on options one level out of here yet
  config = {
    #TODO plugins to explore or setup still
    # harpoon #file nav
    # surround #tim pope's surround solution
    # vim-grepper
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

    #
    # ========== bars/lines ==========
    #
    nixvim-config.plugins.bufferline.enable = lib.mkDefault false;
    nixvim-config.plugins.lualine.enable = lib.mkDefault true;
    #
    # ========== trees ??? ==========
    #
    nixvim-config.plugins.neo-tree.enable = lib.mkDefault true;
    nixvim-config.plugins.undotree.enable = lib.mkDefault true;
    #
    # ========== git ==========
    #
    nixvim-config.plugins.neogit.enable = lib.mkDefault false;
    nixvim-config.plugins.fugitive.enable = lib.mkDefault true;
    #nixvim-config.plugins.lazygit.enable = lib.mkDefault false;

    #
    # ========== completion ==========
    #
    nixvim-config.plugins.cmp.enable = lib.mkDefault false;
    nixvim-config.plugins.copilot.enable = lib.mkDefault false;

    #
    # ========== languages ==========
    #
    #       nixvim-config.plugins.treesitter.enable = lib.mkDefault true;
    #       nixvim-config.plugins.nvim-lint.enable = lib.mkDefault true;

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
  };
}
