{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)

      calibre
      ffmpeg
      spotify
      vlc
      ;
  };
}
