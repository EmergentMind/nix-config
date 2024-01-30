{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    #################### Required Configs #################### 
    common/core  #required

    #################### Host-specific Optional Configs #################### 
    common/optional/sops.nix
    common/optional/helper-scripts

#FIXME change to just common/optional/desktops after hyprland is working
    common/optional/desktops/hyprland/binds.nix
  ];
}
