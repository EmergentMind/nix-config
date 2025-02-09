{
  lib,
  stdenv,
  fetchFromGitHub,
}:

let
  pname = "fish-title";
  install_path = "share/fish/vendor_functions.d"; # Location for fish functions
  url = "https://github.com/oh-my-fish/plugin-title";
in
stdenv.mkDerivation {
  inherit pname;
  version = "latest"; # Optionally specify a commit or release version
  src = fetchFromGitHub {
    owner = "oh-my-fish";
    repo = "plugin-title";
    rev = "master"; # Use specific commit hash if preferred
    sha256 = "15f9xrp4b5hfa26v2j428izfcmv47v5kyhbxxa4cyz6s19llsxiv"; # Replace with actual hash from nix-prefetch-url
  };

  dontBuild = true;
  installPhase = ''
    install -m755 -D title.fish $out/${install_path}/title.fish
  '';

  meta = {
    description = "A Fish plugin to set the terminal title based on the current command and directory.";
    homepage = url;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.oh-my-fish ];
  };
}
