#
# This file defines overlays/custom modifications to upstream packages
#

{ inputs, lib, ... }:
let
  overlays = {
    # Adds my custom packages
    # FIXME: Add per-system packages
    additions =
      final: prev:
      let
        # system = final.stdenv.hostPlatform.system;
      in
      (
        prev.lib.packagesFromDirectoryRecursive {
          callPackage = prev.lib.callPackageWith final;
          directory = ../pkgs;
        }
        # Any nixpkgs PRs that aren't upstream yet
        // {
        }
      )
      # Other external inputs
      // {
      };

    linuxModifications =
      final: prev:
      lib.optionalAttrs prev.stdenv.isLinux ({
        # linuxPackages_6_18 = prev.linuxPackages_6_18.extend (
        #   _lfinal: lprev: {
        #     xpadneo = lprev.xpadneo.overrideAttrs (old: {
        #       patches = (old.patches or [ ]) ++ [
        #         (prev.fetchpatch {
        #           url = "https://github.com/orderedstereographic/xpadneo/commit/233e1768fff838b70b9e942c4a5eee60e57c54d4.patch";
        #           hash = "sha256-HL+SdL9kv3gBOdtsSyh49fwYgMCTyNkrFrT+Ig0ns7E=";
        #           stripLen = 2;
        #         })
        #       ];
        #     });
        #   }
        # );
        neovim = final.unstable.neovim;
        neovide = final.unstable.neovide;
        vimPlugins = final.unstable.vimPlugins;
      });

    modifications = final: prev: {
      # example = prev.example.overrideAttrs (previousAttrs: let ... in {
      # ...
      # });
    };

    unstable-packages = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
        overlays = [
          # (unstable_final: unstable_prev: {
          #   bootdev-cli = unstable_prev.bootdev-cli.overrideAttrs (
          #     previousAttrs:
          #     let
          #       version = "1.29.2";
          #       hashes = {
          #         "1.29.2" = "sha256-POOxwveDSQ3hiybFKmI2eQQEbxN45ubmfEUkLk7i/ng=";
          #       };
          #     in
          #     rec {
          #       inherit version;
          #       src = prev.fetchFromGitHub {
          #         owner = "bootdotdev";
          #         repo = "bootdev";
          #         tag = "v${version}";
          #         hash = hashes.${version} or "";
          #       };
          #       vendorHash = "sha256-ZDioEU5uPCkd+kC83cLlpgzyOsnpj2S7N+lQgsQb8uY=";
          #     }
          #   );
          # })
        ];
      };
    };
  };
in
{
  default =
    final: prev:
    lib.attrNames overlays
    |> map (name: (overlays.${name} final prev))
    # nixfmt hack
    |> lib.mergeAttrsList;
}
