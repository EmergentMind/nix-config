# Fuzzy finder for Ex commands (:), search history (/), and command history (?)
{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.wilder.enable = lib.mkEnableOption "enables wilder module";
  };

  config = lib.mkIf config.nixvim-config.plugins.wilder.enable {
    programs.nixvim.plugins = {
      wilder = {
        enable = true;
        modes = [
          ":"
          "/"
          "?"
        ]; # enable in all modes
        pipeline = [
          ''
            wilder.branch(wilder.python_file_finder_pipeline({
                file_command = function(_, arg)
                    if string.find(arg, ".") ~= nil then
                        return {"fd", "-tf", "-H"}
                    else
                        return {"fd", "-tf"}
                    end
                end,
                dir_command = {"fd", "-td"},
                filters = {"fuzzy_filter", "difflib_sorter"}
            }), wilder.cmdline_pipeline(), wilder.python_search_pipeline())
          ''
        ];
        renderer = ''
          wilder.popupmenu_renderer({
              highlighter = wilder.basic_highlighter(),
              left = {" "},
              right = {" ", wilder.popupmenu_scrollbar({thumb_char = " "})},
              highlights = {default = "WilderMenu", accent = "WilderAccent"}
          })
        '';
      };
    };
  };
}
