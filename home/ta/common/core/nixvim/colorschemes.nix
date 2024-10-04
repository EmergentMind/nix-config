{ config, lib, ... }:
{
  options = {
    nixvim-config.colorschemes.enable = lib.mkEnableOption "enables colorschemes module";
  };

  config = lib.mkIf config.nixvim-config.colorschemes.enable {
    programs.nixvim = {
      colorschemes = {
        gruvbox = {
          enable = true;
          settings = {
            contrastDark = true;
            transparentBg = true;
          };
        };
      };
    };
  };
}
