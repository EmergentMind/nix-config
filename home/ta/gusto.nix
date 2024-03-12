{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    #################### Required Configs ####################
    common/core #required

    #################### Host-specific Optional Configs ####################
    common/optional/sops.nix
    common/optional/helper-scripts

    common/optional/desktops/gtk.nix
    common/optional/browsers/brave.nix # for testing against 'media' user
  ];
}
