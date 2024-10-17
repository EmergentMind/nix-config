{
  pkgs,
  config,
  lib,
  ...
}:

let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs =
      pkgs:
      (builtins.attrValues {
        inherit (pkgs.xorg)
          libXcursor
          libXi
          libXinerama
          libXScrnSaver
          ;

        inherit (pkgs.stdenv.cc.cc)
          lib
          ;

        inherit (pkgs)
          libpng
          libpulseaudio
          libvorbis
          libkrb5
          keyutils
          gperftools
          ;

      });
  };

  monitor = lib.head (lib.filter (m: m.primary) config.monitors);

  steam-session =
    let
      gamescope = lib.concatStringsSep " " [
        (lib.getExe pkgs.gamescope)
        "--output-width ${toString monitor.width}"
        "--output-height ${toString monitor.height}"
        "--framerate-limit ${toString monitor.refreshRate}"
        "--prefer-output ${monitor.name}"
        "--adaptive-sync"
        "--expose-wayland"
        "--steam"
        #"--hdr-enabled"
      ];
      steam = lib.concatStringsSep " " [
        "steam"
        #"steam://open/bigpicture"
      ];
    in
    pkgs.writeTextDir "share/applications/steam-session.desktop" ''
      [Desktop Entry]
      Name=Steam Session
      Exec=${gamescope} -- ${steam}
      Icon=steam
      Type=Application
    '';
in
{
  home.packages = [
    steam-with-pkgs
    steam-session
    pkgs.gamescope
    pkgs.protontricks
  ];
}
