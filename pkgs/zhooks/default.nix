{
  lib,
  stdenv,
  fetchgit,
}:
let
  pname = "zhooks";
in
stdenv.mkDerivation {
  inherit pname;
  version = "e6616b4a2786b45a56a2f591b79439836e678d22";
  src = fetchgit {
    url = "https://github.com/agkozak/zhooks";
    hash = "sha256-zahXMPeJ8kb/UZd85RBcMbomB7HjfEKzQKjF2NnumhQ=";
  };
  strictDeps = true;
  dontBuild = true;
  installPhase = ''
    install -m755 -D zhooks.plugin.zsh --target-directory $out/share/zsh/zhooks/
  '';
  meta = {
    homepage = "https://github.com/agkozak/zhooks";
    license = lib.licenses.mit;
    description = "zhooks is a tool for displaying the code for all Zsh hook functions (such as precmd), as well as the contents of hook arrays (such as precmd_functions).";
    maintainers = [ lib.maintainers.fidgetingbits ];
  };
}
