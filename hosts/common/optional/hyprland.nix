{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.hyprlandPlugins.hy3
  ];
}
