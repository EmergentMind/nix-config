{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.fugitive.enable = lib.mkEnableOption "enables fugitive module";
  };

  config = lib.mkIf config.nixvim-config.plugins.fugitive.enable {
    programs.nixvim = {
      plugins.fugitive = {
        enable = true;
      };
    };
  };
}
