{ configLib, ... }:
{
  imports = configLib.scanPaths ./.;
}
