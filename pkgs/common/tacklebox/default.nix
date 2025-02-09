{
  lib,
  stdenv,
  fetchgit,
}:
let
  pname = "tacklebox";
in
stdenv.mkDerivation {
  inherit pname;
  version = "latest"; # Specify a specific commit hash or version if needed
  src = fetchgit {
    url = "https://github.com/justinmayer/tacklebox";
    # Replace this with the actual sha256 hash, e.g., by running nix-prefetch-url
    sha256 = "0r7x1g8vv7z00wfd9g48zr1h86rlxgydinlramydfl7gr923a3nd";
  };
  strictDeps = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fish/${pname}
    cp -r * $out/share/fish/${pname}
  '';
  meta = {
    homepage = "https://github.com/justinmayer/tacklebox";
    license = lib.licenses.mit;
    description = "Tacklebox is a Fish shell configuration framework that organizes and loads Fish functions and utilities, allowing users to set up hook-like functions similar to Zsh hooks.";
    maintainers = [ lib.maintainers.justinmayer ];
  };
}
