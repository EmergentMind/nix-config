# Add your reusable NixOS modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.

{
  backup = import ./backup;
  semi-active-av = import ./semi-active-av.nix;
  yubikey = import ./yubikey;
  zsa-udev-rules = import ./zsa-udev-rules.nix;
}
