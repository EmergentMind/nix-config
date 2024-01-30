{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    #################### Required Configs #################### 
    common/core  #required

    #################### Host-specific Optional Configs #################### 
    common/optional/sops.nix
    common/optional/desktops
  ];
}
