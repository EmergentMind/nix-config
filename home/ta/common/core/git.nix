{
  pkgs,
  lib,
  config,
  configLib,
  configVars,
  ...
}:
let
  handle = configVars.handle;
  publicGitEmail = configVars.gitHubEmail;
  publicKey = "${config.home.homeDirectory}/.ssh/id_yubikey.pub";
  username = configVars.username;
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = handle;
    userEmail = publicGitEmail;
    aliases = { };
    extraConfig = {
      log.showSignature = "true";
      init.defaultBranch = "main";
      pull.rebase = "true";
      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
        "ssh://git@gitlab.com" = {
          insteadOf = "https://gitlab.com";
        };
      };

      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signing.key = "${publicKey}";
      # Taken from https://github.com/clemak27/homecfg/blob/16b86b04bac539a7c9eaf83e9fef4c813c7dce63/modules/git/ssh_signing.nix#L14
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";

      save.directory = "${config.home.homeDirectory}/sync/obsidian-vault-01/wiki";
    };
    signing = {
      signByDefault = true;
      key = publicKey;
    };
    ignores = [
      ".csvignore"
      ".direnv"
      "result"
    ];
  };
  # NOTE: To verify github.com update commit signatures, you need to manually import
  # https://github.com/web-flow.gpg... would be nice to do that here
  home.file.".ssh/allowed_signers".text = ''
    ${publicGitEmail} ${lib.fileContents (configLib.relativeToRoot "hosts/common/users/${username}/keys/id_maya.pub")}
    ${publicGitEmail} ${lib.fileContents (configLib.relativeToRoot "hosts/common/users/${username}/keys/id_mara.pub")}
    ${publicGitEmail} ${lib.fileContents (configLib.relativeToRoot "hosts/common/users/${username}/keys/id_manu.pub")}
  '';
}
