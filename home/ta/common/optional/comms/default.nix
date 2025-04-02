{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      #telegram-desktop
      discord
      slack
      ;
    inherit (pkgs.unstable)
      signal-desktop
      ;
  };
}
