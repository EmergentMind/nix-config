# Expose programs.llm
# Originally from https://github.com/EricCrosson/dotfiles/blob/3230246e6d782e8e3cd6decf809d9ac6b2c845b4/modules/home-manager/programs/llm/default.nix
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.llm;
  yamlFormat = pkgs.formats.yaml { };

  # Helper function to convert model to attributes
  modelToAttrs = model: {
    model_id = model.id;
    model_name = model.name;
    inherit (model) api_base;
  };
in
{
  options.programs.llm = {
    enable = lib.mkEnableOption "LLM CLI configuration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llm;
      defaultText = lib.literalExpression "pkgs.llm";
      description = "The LLM package to use.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = ".config/io.datasette.llm";
      description = "Directory for LLM configuration files (relative to home directory)";
      readOnly = true;
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      description = "Default model to use";
    };

    models = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.str;
              description = "Model identifier";
              example = "bedrock-claude-sonnet";
            };

            name = lib.mkOption {
              type = lib.types.str;
              description = "Full model name";
              example = "bedrock/us.anthropic.claude-sonnet-4-5-20250929-v1:0";
            };

            api_base = lib.mkOption {
              type = lib.types.str;
              description = "API base URL";
              example = "http://localhost:4000";
            };

            api_key = lib.mkOption {
              type = lib.types.str;
              description = "API key";
              example = "foo";
            };

          };
        }
      );
      description = "List of models to configure for LLM CLI";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = {
        "${cfg.configDir}/default_model.txt".text = cfg.defaultModel;

        "${cfg.configDir}/extra-openai-models.yaml".source =
          yamlFormat.generate "llm-extra-openai-models.yaml" (map modelToAttrs cfg.models);
      };

      packages = [ cfg.package ];
      sessionVariables = {
        LLM_USER_PATH = "${config.home.homeDirectory}/${cfg.configDir}";
      };
    };
  };
}
