# Shell for bootstrapping flake-enabled nix and other tooling
{
  pkgs,
  checks,
  lib,
  ...
}:
{
  default = pkgs.mkShell {
    # Nix utility settings
    NIX_CONFIG = "extra-experimental-features = nix-command flakes pipe-operators";
    NIXPKGS_ALLOW_BROKEN = "1";

    # Bootstrap script settings
    BOOTSTRAP_USER = "ta";
    BOOTSTRAP_SSH_PORT = "22";
    BOOTSTRAP_SSH_KEY = "~/.ssh/id_yubikey";
    NIX_SECRETS_DIR = "/home/ta/dev/nix/nix-secrets";

    buildInputs = checks.pre-commit-check.enabledPackages;
    nativeBuildInputs =
      lib.attrValues {
        inherit (pkgs)
          home-manager
          git
          just
          pre-commit
          sops
          statix
          git-crypt # encrypt secrets in git not suited for sops
          attic-client # for attic backup

          json-diff # noctalia settings diffing

          age # bootstrap script
          ssh-to-age # bootstrap script
          gum # shell script ricing
          ;
        inherit (pkgs.introdus)
          bootstrap-nixos # introdus script for bootstrapping new hosts
          check-sops
          pin-systemd-boot-entry
          json2nix
          ;
      }
      ++ [
        # introdus script for rebuilding a remote/local hosts
        # with optional per-host locking support
        (pkgs.introdus.rebuild-host.overrideAttrs (_: {
          perHostLocks = false;
        }))
        # New enough to get memory management improvements
        pkgs.unstable.nixVersions.git
      ];
    inherit (checks.pre-commit-check) shellHook;
  };
}
