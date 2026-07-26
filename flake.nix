{
  description = "EmergentMind's Nix-Config";
  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      introdus,
      nix-secrets,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      namespace = "emergentmind"; # namespace for our custom modules. Snowfall lib style

      introdusLib = introdus.lib.mkIntrodusLib {
        inherit (nixpkgs) lib;
        secrets = nix-secrets;
      };
      customLib = nixpkgs.lib.extend (
        self: super: {
          custom =
            introdusLib
            # NOTE: This overrides introdusLib entries with local changes via
            # '//' in case I want to test something
            // (import ./lib {
              inherit (nixpkgs) lib;
            });
        }
      );

      secrets = nix-secrets.mkSecrets nixpkgs customLib;

      mkHost = host: isDarwin: {
        ${host} =
          let
            func = if isDarwin then inputs.nix-darwin.lib.darwinSystem else lib.nixosSystem;
            systemFunc = func;
            # Propagate lib.custom into hm
            # see: https://github.com/nix-community/home-manager/pull/3454
          in
          systemFunc {
            specialArgs = rec {
              inherit
                inputs
                outputs
                namespace
                secrets
                ;
              lib = customLib;
              inherit isDarwin;
            };
            modules = [
              ./hosts/${if isDarwin then "darwin" else "nixos"}/${host}
            ];
          };
      };

      # FIXME: Move this
      # Bare minimum configuration for a host for faster initial install testing
      mkMinimalHost = host: {
        "${host}Minimal" = lib.nixosSystem {
          # FIXME: This will break when we add aarch64, so set it via in hostSpec maybe?
          system = "x86_64-linux";
          # FIXME:This should merge with the above specialArgs
          specialArgs = {
            inherit
              inputs
              outputs
              namespace
              secrets
              ;
            lib = customLib;
            isDarwin = false;
          };
          modules = lib.flatten (
            [
              # FIXME: See if we can lift this from elsewhere now that we aren't standalone
              {
                nixpkgs.overlays = [
                  (final: prev: {
                    unstable = import inputs.nixpkgs-unstable {
                      inherit (final.stdenv.hostPlatform) system;
                      config.allowUnfree = true;
                    };
                  })
                  introdus.overlays.default
                ];
              }
              inputs.home-manager.nixosModules.home-manager
            ]
            ++
              # FIXME: If this moves to introdus, the hosts path need to become relative to the caller
              # not introdus
              (map customLib.custom.relativeToRoot [
                # Minimal modules for quick setup
                "modules/hosts/common/host-spec.nix"
                "modules/hosts/nixos/disks.nix"

                "hosts/nixos/${host}/host-spec.nix"
                "hosts/nixos/${host}/disks.nix"

                "hosts/common/optional/minimal-configuration.nix"
              ])
            ++ lib.optional (lib.pathExists ./hosts/nixos/${host}/facter.json) [
              inputs.nixos-facter-modules.nixosModules.facter
              {
                config.facter.reportPath = customLib.custom.relativeToRoot "hosts/nixos/${host}/facter.json";
              }
            ]
          );
        };
      };

      mkHostConfigs =
        hosts: isDarwin:
        lib.foldl (acc: set: acc // set) { } (
          (lib.map (host: mkHost host isDarwin) hosts)
          ++ (lib.map (host: mkMinimalHost host) (lib.filter (h: h != "iso") hosts))
        );
      readHosts = folder: lib.attrNames (lib.readDir ./hosts/${folder});

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        # Custom modifications/overrides to upstream packages
        overlays = import ./overlays {
          inherit inputs lib secrets;
        };
        # Build host configs
        nixosConfigurations = mkHostConfigs (readHosts "nixos") false;
        # darwinConfigurations = mkHostConfigs (readHosts "darwin") true;
      };
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              introdus.overlays.default
              self.overlays.default
            ];
          };
          formatter = inputs.introdus.formatter.${system};
        in
        rec {
          # Expose custom packages
          _module.args.pkgs = pkgs;
          packages = lib.packagesFromDirectoryRecursive {
            callPackage = lib.callPackageWith pkgs;
            directory = ./pkgs;
          };
          # FIXME: There might be a better way to auto-integrate the introdus formatter
          checks = import ./checks {
            inherit
              inputs
              pkgs
              system
              lib
              formatter
              ;
          };
          # Nix formatter available through 'nix fmt' https://github.com/NixOS/nixfmt
          inherit formatter;
          # Custom shell for bootstrapping, nix-config dev, and secrets management
          devShells = import ./shell.nix {
            inherit
              checks
              inputs
              system
              pkgs
              lib
              ;
          };
        };
    };

  inputs = {
    #
    # ========= Official NixOS, Darwin, and HM Package Sources =========
    #
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # The next two are for pinning to stable vs unstable regardless of what the above is set to
    # This is particularly useful when an upcoming stable release is in beta because you can effectively
    # keep 'nixpkgs-stable' set to stable for critical packages while setting 'nixpkgs' to the beta branch to
    # get a jump start on deprecation changes.
    # See also 'stable-packages' and 'unstable-packages' overlays at 'overlays/default.nix"
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    # Modern nixos-hardware alternative
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #
    # ========= Utilities =========
    #
    # Utility wrappers
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    # Secrets management. See ./docs/secretsmgmt.md
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative vms using libvirt
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Firefox
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox2nix = {
      url = "git+https://git.sr.ht/~rycee/mozilla-addons-to-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # desktop shell
    noctalia = {
      #FIXME: pinned to 4.7.7 until 5.x becomes more stable (still alpha as 26.06.09)
      url = "github:noctalia-dev/noctalia?ref=v4.7.7";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    #
    # ========= Ricing =========
    #
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #
    # ========= Personal Repositories =========
    #
    # this is a separate input for dev hosts that don't have a local copy of introdus
    introdus-git = {
      url = "git+ssh://git@codeberg.org/fidgetingbits/introdus?ref=ta";
    };
    introdus = {
      # url = "git+ssh://git@codeberg.org/fidgetingbits/introdus?shallow=1&ref=ta";
      url = "path:///home/ta/dev/nix/introdus/ta";
    };
    # Private secrets repo.  See ./docs/secretsmgmt.md
    # Authenticate via ssh and use shallow clone
    nix-secrets = {
      url = "git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-assets = {
      url = "git+ssh://git@codeberg.org/emergentmind/nix-assets";
    };
    emergentvim = {
      # url = "git+ssh://git@codeberg.org/emergentmind/neovim";
      url = "path:///home/ta/dev/nix/neovim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.introdus.follows = "introdus";
      inputs.flake-parts.follows = "flake-parts";
    };
  };
}
