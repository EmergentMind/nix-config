# You can build these directly using 'nix build .#example'

{
  pkgs ? import <nixpkgs> { },
}:
rec {

  #################### Packages with external source ####################

  fish-cd-gitroot = pkgs.callPackage ./fish-cd-gitroot { };
  tacklebox = pkgs.callPackage ./tacklebox { };
  oh-my-fish = pkgs.callPackage ./oh-my-fish { };
}
