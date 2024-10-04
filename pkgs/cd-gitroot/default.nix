{
  lib,
  stdenv,
  fetchgit,
}:
let
  pname = "cd-gitroot";
  install_path = "share/zsh/${pname}";
in
stdenv.mkDerivation {
  inherit pname;
  version = "66f6ba7549b9973eb57bfbc188e29d2f73bf31bb";
  src = fetchgit {
    url = "https://github.com/mollifier/cd-gitroot";
    hash = "sha256-pLdF8wbkA9mPI5cg8VPYAW7i3cWNJX3+lfAZ5cZPUgE=";
  };
  strictDeps = true;
  dontBuild = true;
  buildInputs = [ ];
  installPhase = ''
    install -m755 -D cd-gitroot.plugin.zsh --target-directory $out/${install_path}/
    install -m755 -D cd-gitroot --target-directory $out/${install_path}/
    install -m755 -D _cd-gitroot --target-directory $out/share/zsh/site-functions/
  '';
  meta = {
    homepage = "https://github.com/mollifier/cd-gitroot";
    license = lib.licenses.mit;
    longDescription = ''
      zsh plugin to change directory to git repository root directory.
          You can add the following to your `programs.zsh.plugins` list:
          ```nix
          programs.zsh.plugins = [
            {
              name = "${pname}";
              src = "''${pkgs.${pname}}/${install_path}";
            }
          ];
          ```
    '';
    maintainers = [ lib.maintainers.fidgetingbits ];
  };
}
