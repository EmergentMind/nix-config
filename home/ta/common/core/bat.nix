# https://github.com/sharkdp/bat
# https://github.com/eth-p/bat-extras

{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      # Git modifications and file header (but no grid)
      style = "changes,header";
      # theme = "gruvbox-dark";
    };
    extraPackages = builtins.attrValues {
      inherit (pkgs.bat-extras)

        batgrep # search through and highlight files using ripgrep
        batdiff # Diff a file against the current git index, or display the diff between to files
        batman # read manpages using bat as the formatter
        ;
    };
  };

  # Avoid [bat error]: The binary caches for the user-customized syntaxes and themes in
  # '/home/<user>/.cache/bat' are not compatible with this version of bat (0.25.0).
  home.activation.batCacheRebuild = {
    after = [ "linkGeneration" ];
    before = [ ];
    data = ''
      ${pkgs.bat}/bin/bat cache --build
    '';
  };

}
