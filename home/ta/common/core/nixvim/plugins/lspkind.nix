{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.lspkind.enable = lib.mkEnableOption "enables lspkind module";
  };

  config = lib.mkIf config.nixvim-config.plugins.lspkind.enable {
    programs.nixvim.plugins.lspkind = {
      enable = true;
      symbolMap = {
        Copilot = "";
      };
      extraOptions = {
        maxwidth = 50;
        ellipsis_char = "...";
      };
    };
  };
}
