{ pkgs, ... }:
{
  imports = [
    #################### Required Configs ####################
    common/core # required

    #################### Host-specific Optional Configs ####################
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      mpv
      ;
  };
}
