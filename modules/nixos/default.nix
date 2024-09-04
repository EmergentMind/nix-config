# Add your reusable NixOS modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.

{ configLib, ... }:
{
  imports = configLib.scanPaths ./.;
}
