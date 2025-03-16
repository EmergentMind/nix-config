{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.protonvpn-cli
    pkgs.protonvpn-gui
  ];
}
