{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)

      signal-desktop
      telegram-desktop
      discord
      slack
      ;
  };
}
