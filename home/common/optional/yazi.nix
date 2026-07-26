{
  ...
}:
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    plugins = {
    };
    settings = {
      mgr = {
        sort_dir_first = true;
        # sort_by = "alphabetical";
        linemode = "mtime";
        # show_hidden = false;
        ratio = [
          1
          2
          5
        ];
      };
      preview = {
        tab_size = 4;
        image_filter = "lanczos3";
        max_width = 2560;
        max_height = 1440;
        image_qualtiy = 90;
      };
    };
  };
  # theme = lib.importTOML ../foo/theme.toml;
  # keymap = lib.importTOML ../foo/keymap.toml;
}
