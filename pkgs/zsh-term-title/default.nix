{
  lib,
  stdenv,
  fetchgit,
}:
let
  pname = "zsh-term-title";
  install_path = "share/zsh/${pname}";
  url = "https://github.com/pawel-slowik/zsh-term-title";
in
stdenv.mkDerivation {
  inherit pname;
  version = "2be2ae96946c5f802827491543de43ac89c9a965";
  src = fetchgit {
    inherit url;
    hash = "sha256-PbIDbSwvRB/1fVzljDzub4ETNJjROllQuY80n8KOcZ0=";
  };
  strictDeps = true;
  dontBuild = true;
  installPhase = ''
    install -m755 -D term-title.plugin.zsh $out/${install_path}/${pname}.plugin.zsh
  '';
  meta = {
    homepage = url;
    license = lib.licenses.mit;
    longDescription = ''
      This Zsh plugin puts current command and working directory in your terminal title. It can also set tmux window name
      and pane title.

      To install the ${pname} plugin in home-manager you can add the following to your `programs.zsh.plugins` list:

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
