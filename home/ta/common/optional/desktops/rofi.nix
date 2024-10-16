{
  pkgs,
  ...
}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    extraConfig = {
      show-icons = true;
      # icon-theme = "";
      # hover-select = true;
      drun-match-fields = "name";
      drun-display-format = "{name}";
      #FIXME not working
      drun-search-paths = "/home/ta/.nix-profile/share/applciations,/home/ta/.nix-profile/share/wayland-sessions";

    };
  };
}
