{  lib, pkgs, ... }:
{
  imports = [ ../hosts/common/users/ta ];

  fileSystems."/boot".options = ["umask=0077"]; # Removes permissions and security warnings.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    # we use Git for version control, so we don't need to keep too many generations.
    # FIXME  lower this even more after testing complete
    configurationLimit = lib.mkDefault 10;
    # pick the highest resolution for systemd-boot's console.
    consoleMode = lib.mkDefault "max";
  };
  boot.initrd.systemd.enable = true;

  networking = {
    # configures the network interface(include wireless) via `nmcli` & `nmtui`
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [22]; # FIXME: Change this to use configVars.networking eventually
    settings = {
      PermitRootLogin = "yes";
    };
    # Fix LPE vulnerability with sudo use SSH_AUTH_SOCK: https://github.com/NixOS/nixpkgs/issues/31611
    # this mitigates the security issue caused by enabling u2fAuth in pam
    authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];
  };
  # yubikey login / sudo
  # this potentially causes a security issue that we mitigated above
  security.pam = {
    enableSSHAgentAuth = true;
    #FIXME the above is deprecated in 24.05 but we will wait until release
    #sshAgentAuth.enable = true;
    services = {
      sudo.u2fAuth = true;
    };
  };

  # ssh-agent is used to pull my private secrets repo from gitlab when deploying nix-config.
 # programs.ssh.startAgent = true;

  environment.systemPackages = builtins.attrValues {
    inherit(pkgs)
    wget
    curl
    rsync;
  };

  virtualisation.virtualbox.guest.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
