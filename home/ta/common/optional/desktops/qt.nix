{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "gtk2";
          # autodetected themes:
          # adwaita, adwaita-dark, adwaita-highcontrast, adwaita-hightcontrastinverse, breeze, bb10bright, bb10dark, cde, cleanlooks, gtk2, motfi, plastique
      #theme package
      package = pkgs.qt6Packages.qt6gtk2;
    };
  };
}