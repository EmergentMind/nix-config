{
  lib,
  stdenv,
  writeText,
}:
let
  pname = "fish-cd-gitroot";
  install_path = "share";
  functions_path = "share/fish/${pname}/functions";
  modules_path = "share/fish/${pname}/modules";
in
stdenv.mkDerivation {
  inherit pname;
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "mollifier";
    repo = "fish-cd-gitroot";
    rev = "master";
    sha256 = "0nsk1v143ksph5m680hw11hpqizpzpkl5dfmwj5wi0hbklipbkm1";
  };
  strictDeps = true;
  dontBuild = true;
  buildInputs = [ ];
  installPhase = ''
    install -m755 -D $src $out/${functions_path}/cd-gitroot.fish
    install -m755 -D $src $out/${modules_path}/cd-gitroot.fish
  '';
  meta = {
    description = "Fish function to change directory to git repository root";
    license = lib.licenses.mit;
    longDescription = ''
      Fish function to change directory to git repository root.
      You can add the following to your `programs.fish.functions` list:
      ```nix
      programs.fish.functions = {
        cd-gitroot = builtins.readFile "''${pkgs.${pname}}/${install_path}/cd-gitroot.fish";
      };
      ```
    '';
    maintainers = [ lib.maintainers.mollifier ];
  };
}
