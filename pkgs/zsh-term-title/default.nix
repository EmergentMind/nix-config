{
  lib,
  stdenv,
  fetchgit,
}:
let
  pname = "zsh-term-title";
in
stdenv.mkDerivation {
  inherit pname;
  version = "2be2ae96946c5f802827491543de43ac89c9a965";
  src = fetchgit {
    url = "https://github.com/pawel-slowik/zsh-term-title";
    hash = "sha256-PbIDbSwvRB/1fVzljDzub4ETNJjROllQuY80n8KOcZ0=";
  };
  strictDeps = true;
  dontBuild = true;
  installPhase = ''
    install -m755 -D term-title.plugin.zsh $out/share/zsh/zsh-term-title/zsh-term-title.plugin.zsh
  '';
  meta = with lib; {
    homepage = "https://github.com/pawel-slowik/zsh-term-title";
    license = licenses.mit;
    description = "This Zsh plugin puts current command and working directory in your terminal title. It can also set tmux window name and pane title.";
    maintainers = with maintainers; [
      fidgetingbits
      emergentmind
    ];
  };
}
