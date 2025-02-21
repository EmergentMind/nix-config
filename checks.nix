{
  inputs,
  system,
  pkgs,
  ...
}:
{
  bats-test =
    pkgs.runCommand "bats-test"
      {
        src = ../.;
        buildInputs = builtins.attrValues { inherit (pkgs) bats yq-go inetutils; };
      }
      ''
        cd $src
        bats tests
        touch $out
      '';

  pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
    src = ./.;
    default_stages = [ "pre-commit" ];
    hooks = {
      # ========== General ==========
      check-added-large-files = {
        enable = true;
        excludes = [
          "\\.png"
          "\\.jpg"
        ];
      };
      check-case-conflicts.enable = true;
      check-executables-have-shebangs.enable = true;
      check-shebang-scripts-are-executable.enable = false; # many of the scripts in the config aren't executable because they don't need to be.
      check-merge-conflicts.enable = true;
      detect-private-keys.enable = true;
      fix-byte-order-marker.enable = true;
      mixed-line-endings.enable = true;
      trim-trailing-whitespace.enable = true;

      forbid-submodules = {
        enable = true;
        name = "forbid submodules";
        description = "forbids any submodules in the repository";
        language = "fail";
        entry = "submodules are not allowed in this repository:";
        types = [ "directory" ];
      };

      destroyed-symlinks = {
        enable = true;
        name = "destroyed-symlinks";
        description = "detects symlinks which are changed to regular files with a content of a path which that symlink was pointing to.";
        package = inputs.pre-commit-hooks.checks.${system}.pre-commit-hooks;
        entry = "${inputs.pre-commit-hooks.checks.${system}.pre-commit-hooks}/bin/destroyed-symlinks";
        types = [ "symlink" ];
      };

      # ========== nix ==========
      nixfmt-rfc-style.enable = true;
      deadnix = {
        enable = true;
        settings = {
          noLambdaArg = true;
        };
      };

      # ========== shellscripts ==========
      shfmt.enable = true;
      shellcheck.enable = true;

      end-of-file-fixer.enable = true;
    };
  };
}
