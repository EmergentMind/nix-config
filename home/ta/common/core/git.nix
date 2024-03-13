{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "emergentmind";
    userEmail = "2889621-emergentmind@users.noreply.gitlab.com";
    aliases = { };
    extraConfig = {
      init.defaultBranch = "main";
      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
        "ssh://git@gitlab.com" = {
          insteadOf = "https://gitlab.com";
        };
      };

      user.signing.key = "41B7B2ECE0FAEF890343124CE8AA1A8F75B56D39";
      #TODO sops - Re-enable once sops setup complete
      commit.gpgSign = false;
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";
    };
    # enable git Large File Storage: https://git-lfs.com/
    # lfs.enable = true;
    ignores = [ ".direnv" "result" ];
  };
}
