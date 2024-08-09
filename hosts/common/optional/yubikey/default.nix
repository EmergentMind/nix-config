# Modeled on https://github.com/Mic92/dotfiles for now

{ pkgs, ... }:
let
  yubikey-up = pkgs.writeShellApplication {
    name = "yubikey-up";
    runtimeInputs = builtins.attrValues { inherit (pkgs) gawk yubikey-manager; };
    text = builtins.readFile ./scripts/yubikey-up.sh;
  };
  yubikey-down = pkgs.writeShellApplication {
    name = "yubikey-down";
    text = builtins.readFile ./scripts/yubikey-down.sh;
  };
in
with pkgs; # FIXME needs to be refactored according to best practices but not sure how in this case. https://nix.dev/guides/best-practices#with-scopes
{
  environment.systemPackages = [
    # yubikey-personalization
    # Yubico's official tools
    #    yubikey-manager
    #    yubikey-manager-qt
    #    yubikey-personalization
    #    yubikey-personalization-gui
    #    yubico-piv-tool
    #    yubioath-flutter # yubioath-desktop on older nixpkg channels
    pam_u2f # for yubikey with sudo

    yubikey-up
    yubikey-down
    yubikey-manager # For ykman
  ];

  # FIXME: Put this behind an option for yubikey ssh
  # Create ssh files

  # FIXME: Not sure if we need the wheel one. Also my idProduct gruop is 0407
  # Yubikey 4/5 U2F+CCID
  # SUBSYSTEM == "usb", ATTR{idVendor}=="1050", ENV{ID_SECURITY_TOKEN}="1", GROUP="wheel"
  # We already have a yubikey rule that sets the ENV variable

  services.udev.extraRules = ''
    # Link/unlink ssh key on yubikey add/remove
    SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"
    SUBSYSTEM=="input", ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"
  '';

  # FIXME: Need to create symlinks to the sops-decrypted keys

  # enable pam services to allow u2f auth for login and sudo
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # Yubikey required services and config. See Dr. Duh NixOS config for reference
  services.pcscd.enable = true; # smartcard service

  services.udev.packages = [ yubikey-personalization ];
}
