{ lib, ... }:
{
  imports = lib.custom.scanPaths ./.;
}
