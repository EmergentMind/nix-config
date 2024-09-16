{ pkgs, ... }:
{
  hardware.keyboard.zsa.enable = true;
  modules.zsa-udev-rules.enable = true; # rules required for flashing zsa keebs https://github.com/zsa/wally/wiki/Linux-install
  environment.systemPackages = [ pkgs.wally-cli ]; # cli zsa keeb flashing tool
}
