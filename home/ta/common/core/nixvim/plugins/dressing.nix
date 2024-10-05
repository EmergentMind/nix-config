# UI improvements
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.dressing.enable = lib.mkEnableOption "enables dressing module";
  };

  config = lib.mkIf config.nixvim-config.plugins.dressing.enable {
    programs.nixvim.plugins = {
      dressing = {
        enable = true;
      };
    };
  };
}
