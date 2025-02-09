{ pkgs, ... }:
{
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs.nvtopPackages)
      amd
      intel
      #nvidia
      ;
  };
}
