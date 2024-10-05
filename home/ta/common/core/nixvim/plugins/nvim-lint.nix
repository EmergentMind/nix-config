# Lint-nvim
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.lint.enable = lib.mkEnableOption "enables lint module";
  };

  config = lib.mkIf config.nixvim-config.plugins.lint.enable {
    programs.nixvim.plugins = {
      lint = {
        enable = true;
        lintersByFt = {
          nix = [ "statix" ];
          lua = [ "selene" ];
          python = [ "flake8" ];
          javascript = [ "eslint_d" ];
          javascriptreact = [ "eslint_d" ];
          typescript = [ "eslint_d" ];
          typescriptreact = [ "eslint_d" ];
          json = [ "jsonlint" ];
          java = [ "checkstyle" ];
        };
      };
    };
  };
}
