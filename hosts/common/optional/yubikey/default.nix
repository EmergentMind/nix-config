# Modeled on https://github.com/Mic92/dotfiles for now

{
  lib,
  pkgs,
  configVars,
  ...
}:
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
  homeDirectory =
    if pkgs.stdenv.isLinux then "/home/${configVars.username}" else "/Users/${configVars.username}";
in
{
  environment.systemPackages = lib.flatten [
    (lib.attrValues {
      inherit (pkgs)
        # Yubico's official tools
        yubioath-flutter # gui-based authenticator tool. yubioath-desktop on older nixpkg channels
        yubikey-manager # cli-based authenticator tool. accessed via `ykman`
        # yubikey-manager-qt
        # yubikey-personalization # enabled below in services.udev
        # yubikey-personalization-gui
        # yubico-piv-tool

        pam_u2f # for yubikey with sudo
        ;
    })
    # custom packages not in nixpkgs
    yubikey-up
    yubikey-down
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

  # Yubikey required services and config. See Dr. Duh NixOS config for reference
  services.pcscd.enable = true; # smartcard service
  services.udev.packages = [ pkgs.yubikey-personalization ];

  services.yubikey-agent.enable = true;

  # yubikey login / sudo
  security.pam = lib.optionalAttrs pkgs.stdenv.isLinux {
    sshAgentAuth.enable = true;
    u2f = {
      enable = true;
      settings = {
        cue = true; # Tells user they need to press the button
        authFile = "${homeDirectory}/.config/Yubico/u2f_keys";
        #debug = true;
      };
    };
    services = {
      login.u2fAuth = true;
      sudo = {
        u2fAuth = true;
        sshAgentAuth = true; # Use SSH_AUTH_SOCK for sudo
      };
    };
  };
}
