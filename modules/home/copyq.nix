# See .config/copyq/
/*
  ❯ ls ~/.config/copyq
   copyq-commands.ini   copyq.conf  󰷖 copyq.pub            copyq_no_session.ini             copyq_tabs.ini
   copyq-filter.ini     copyq.lock   copyq_geometry.ini   copyq_tab_JmNsaXBib2FyZA==.dat   themes

  See how to find all the defaults for the config and auto-generate nix options?
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.copyq;
  configDir =
    if (pkgs.stdenv.isDarwin && !config.xdg.enable) then
      # TODO(darwin): Someone on Darwin can confirm this
      "Library/Preferences/copyq"
    else
      "${config.xdg.configHome}/copyq";
in
{
  options.programs.copyq = {
    enable = lib.mkEnableOption "copyq";
    package = lib.mkPackageOption pkgs "copyq" { };

    settings = {
      Options = {
        close_on_unfocus = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file = {
      "${configDir}/copyq.conf" = lib.mkIf (cfg.settings != { }) lib.generators.toINI { } cfg.settings;
    };
  };
}
