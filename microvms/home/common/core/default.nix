# base home-manager module for microvms
{
  pkgs,
  lib,
  user,
  vmSpecs,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "home/common/optional/zellij"
    ])
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

    packages = lib.attrValues {
      inherit (pkgs)
        curl
        delta
        difftastic
        direnv
        fd
        git
        htop
        jq
        just
        neovim # FIXME: (overlay our neovim package, etc?)
        openssh
        python3
        ripgrep
        strace
        tree
        wget
        ;
    };
  };

  xdg.enable = true;

  programs = {
    home-manager.enable = true;
    zsh = {
      enable = true;
      shellAliases = {
        "cds" = "cd ${vmSpecs.sharedDir}/shared/$(hostname)/";
      };
    };
  };

}
