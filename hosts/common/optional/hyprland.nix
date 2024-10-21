{ inputs, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.hyprlandPlugins.hy3
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];
}
