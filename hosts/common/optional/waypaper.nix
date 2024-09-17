{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.waypaper
    pkgs.swww # backend wallpaper daemon required by waypaper
  ];
}
