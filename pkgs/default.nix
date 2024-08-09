# You can build these directly using 'nix build .#example'

{
  pkgs ? import <nixpkgs> { },
}:
rec {

  #################### Packages with external source ####################

  cd-gitroot = pkgs.callPackage ./cd-gitroot { };
  zhooks = pkgs.callPackage ./zhooks { };
  zsh-term-title = pkgs.callPackage ./zsh-term-title { };
}
