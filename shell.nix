# Shell for bootstrapping flake-enabled nix and other tooling
{
  pkgs ?
    # If pkgs is not defined, instanciate nixpkgs from locked commit
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { overlays = [ ]; },
  checks,
  ...
}:
{ 
          default = pkgs.mkShell {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

            inherit (checks.pre-commit-check) shellHook;
            buildInputs = checks.pre-commit-check.enabledPackages;

            nativeBuildInputs = builtins.attrValues {
              inherit (pkgs)

                nix
                home-manager
                git
                just

                age
                ssh-to-age
                sops
                ;
            };
          };
}

