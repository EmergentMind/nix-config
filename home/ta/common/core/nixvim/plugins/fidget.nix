# LSP Progress Indicator
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.fidget.enable = lib.mkEnableOption "enables fidget module";
  };

  config = lib.mkIf config.nixvim-config.plugins.fidget.enable {
    programs.nixvim.plugins = {
      fidget = {
        enable = true;
      };
    };
  };
}
