{ inputs, lib, pkgs, config, outputs, ... }:
{
  #FIXME stage 2: change to gusto.nix when working
  imports = [
    #################### Required Configs #################### 
    common/core  #required

    #################### Host-specific Optional Configs #################### 
  ];
}
