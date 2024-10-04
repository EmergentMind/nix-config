{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.auto-session.enable = lib.mkEnableOption "enables auto-session module";
  };

  config = lib.mkIf config.nixvim-config.plugins.auto-session.enable {
    programs.nixvim.plugins = {
      auto-session = {
        enable = true;
        logLevel = "error";
        autoSave.enabled = true;
        autoRestore.enabled = false;
        autoSession = {
          suppressDirs = [
            "~/"
            "~/downloads"
            "~/doc"
            "~/tmp"
          ];
          useGitBranch = true; # include git branch name in session name to differentiate btwn sessions for different branches
        };
      };
    };
  };
}
