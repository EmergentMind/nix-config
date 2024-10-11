{ lib, config, ... }:
{
  options.monitors = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            example = "DP-1";
          };
          primary = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          noBar = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          width = lib.mkOption {
            type = lib.types.int;
            example = 1920;
          };
          height = lib.mkOption {
            type = lib.types.int;
            example = 1080;
          };
          refreshRate = lib.mkOption {
            type = lib.types.int;
            default = 60;
          };
          x = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
          y = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
          scale = lib.mkOption {
            type = lib.types.number;
            default = 1.0;
          };
          transform = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          workspace = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      }
    );
    default = [ ];
  };
  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ];
  };
}
