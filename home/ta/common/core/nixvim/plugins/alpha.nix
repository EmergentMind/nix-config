{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.alpha.enable = lib.mkEnableOption "enables alpha module";
  };

  config = lib.mkIf config.nixvim-config.plugins.alpha.enable {
    programs.nixvim.plugins = {
      web-devicons.enable = true; # Required for plugins.alpha
      alpha = {
        enable = true;
        layout = [
          {
            type = "padding";
            val = 2;
          }
          {
            type = "text";
            opts = {
              position = "center";
            };
            val = [
              ""
              "                            *                             "
              "                            *                             "
              "                            *                             "
              "                            **                            "
              "                            **                            "
              "                            **                            "
              "                            **                            "
              "                            **                            "
              "                            **                            "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                           ****                           "
              "                          *****                           "
              "                         ****                             "
              "                       *****                              "
              "                      ****                                "
              "                    ****                                  "
              "                  *****************                       "
              "                 *******************                      "
              "               ****               ****                    "
              "              ***                  ****                   "
              "            ****                    ****                  "
              "           ****                      ****                 "
              "         ****                         ****                "
              "        ****                            ***               "
              "       ***                               ****             "
              "     ***                                  ****            "
              "    **                                     ****           "
              "   *                                        ****          "
              " *                                           ****         "
              "                                               ***        "
              "                                                ***       "
              "                                                 ***      "
              "                                                  ***     "
              "                                                    **    "
              "                                                     **   "
              "                                                       *  "
              "                                                        * "
              "                                                         *"
              ""
            ];
          }
          {
            type = "group";
            val = [
              {
                type = "button";
                val = "   New file";
                on_press.raw = "function() vim.cmd[[ene]] end";
                opts = {
                  shortcut = " <Leader>cn ";
                  position = "center";
                };
              }
              {
                type = "button";
                val = "   Quit Neovim";
                on_press.raw = "function() vim.cmd[[qa]] end";
                opts = {
                  shortcut = " :q ";
                  position = "center";
                };
              }
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "text";
            val = "The way out is through.";
            opts = {
              hl = "Keyword";
              position = "center";
            };
          }
        ];
      };
    };
  };
}
