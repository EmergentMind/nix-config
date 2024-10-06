{
  lib,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.);

  #   config = lib.mkIf config.nixvim-config.enable {  # don't want to gif on options one level out of here yet
  config = {
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
    nixvim-config.plugins.todo-comments.enable = lib.mkDefault true;
    nixvim-config.plugins.which-key.enable = lib.mkDefault true;
  };
}
