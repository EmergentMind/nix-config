# Change Log
NOTE: This changelog is currently only be used to describe large PRs that are too unweildy to explain in a commit message. This may change in the future as the repo evolves but for now, only expect updates here if a commit message explicity references this file.

## 05.12.24 - hostSpec refactor

This is a significant refactor that involves several breaking changes.

- `nix-config/vars` and the associated `configVars` attribute have been eliminated in favor of `nix-config/modules/common/host-spec.nix` which is accessible via `hostSpec`.

	- `configVars` was global to the entire nix-config and began limited design decisions. All of the variables defined for `configVars`, as well as additional ones, are available as `hostSpec` options, many of which have default values. `hostSpec` option values can be declared on a per-host basis.
	- User related options in `hostSpec` are oriented around the "primary" user of a given host and are therefore declared in the host-level common core so they are easily applied to all hosts, where as other options are defined in the host configs.

- Custom library functions previously accessed via `configLib` are now accessible via `lib.custom`. There were many scenarios where both `lib` and `configLib` were being passed as arguments. This change eliminates the need to pass `configLib`.
- Support for both darwin and nixos platforms. This required some structural enhancements as described below
- Several directory paths now have an additional layer of directories to separate files that are common to both darwin and nixos systems or are specific to one.

	- `nixos` and `darwin` sub-directories were added to `nix-config/hosts/` to delineate between the different each hosts underlying system. E.g. `nix-config/hosts/nixos/<hostname>`
	- `common` and `darwin` directories have been added to `nix-config/modules`. One of the modules that was previously in `/nix-config/modules/hosts/nixos` has been moved to `/nix-config/modules/common`
	- `common`, `darwin`, and `nixos` directories have been added to `nix-config/pkgs`

- `darwin.nix` and `nixos.nix` have been added to several locations to separate out declarations that are specific to either OS. Declarations applicable to both OSes remain in the `default.nix` file for the respective directory. Locations include:

	- `nix-config/hosts/common/core`
	- `nix-config/hosts/common/users/<user>/`
	- `nix-config/home/<users>common/core/`
	Additionally, logic has been added to the `default.nix` files in the above directories that will selectively import the appropriate OS file based on the host.

- `nix-config/flake.nix` has been streamline to make use of the structural changes and eliminate duplicate entry for hosts. Of note:

	- host configurations are now dynamically parse based on their location in the structure and as well as `hostSpec` settings rather than being manually defined.
	- `inputs` are now declared below `outputs` since they are infrequently changed and I was tired of having to move down to get to what I wanted in the file

- `nix-config/pkgs` files previously named `default.nix` have been renamed `package.nix`
- The `iso` host has been modified to make it a more useful environment to work in under various scenarios such as experimentation and failed host recovery. The changes include:

	- the iso now imports `nix-config/home/ta/common/core`.
	- the iso is no longer considered minimal and therefore does not set the `isMinimal` flag to true.
	- the iso has been moved from `nix-config/nixos-installer/iso` to `nix-config/hosts/nixos/iso`
	- the `just iso` recipe now creates a symlink called `nix-config/latest.iso` that links to `result/iso/foo.iso`

- Documentation styling has been unified throughout nix-config to improve visual appearance and readability. This may not be to everyone's taste but I like it and at least it's now consistent throughout (unless I've missed something).
- The anatomy diagram accessible through README.md on github has been updated to reflect the changes.
- A forthcoming article will be published to unmovedcentre.com detailing some of the thinking behind the changes.
