#
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.treesiter.enable = lib.mkEnableOption "enables treesiter module";
  };

  config = lib.mkIf config.nixvim-config.plugins.treesiter.enable {
    programs.nixvim.plugins = {
      treesiter = {
        enable = true;
        indent = true;
        folding = true;
        nixvimInjections = true;
      };
    };
  };
}
