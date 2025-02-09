# Fancy and searchable comments for todo, fixmen etc
# https://github.com/folke/todo-comments.nvim
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.todo-comments.enable = lib.mkEnableOption "enables todo-comments module";
  };

  config = lib.mkIf config.nixvim-config.plugins.todo-comments.enable {
    programs.nixvim.plugins = {
      todo-comments = {
        enable = true;
        settings = {
          # patterns from: https://github.com/folke/todo-comments.nvim/issues/10
          search.pattern = "\b(KEYWORDS)(\([^\)]*\))?:";
          highlight.pattern = ".*<((KEYWORDS)%(\(.{-1,}\))?):";
        };
      };
    };
  };
}
