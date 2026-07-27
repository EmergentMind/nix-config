{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.llm-tools;
  server = "ghost.${osConfig.hostSpec.domain}";
  port = osConfig.hostSpec.networking.ports.tcp.llama-swap;
in
{
  options = {
    llm-tools = {
      enable = lib.mkEnableOption "Enable AI client tooling";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        pkgs.llama-cpp # offline inference (llama, deepseek, qwen, etc)
      ];
    };

    # online inference (llama-swap, claude, gemini, openai, etc)
    programs.llm =
      let
        # FIXME: This needs to get updated for ossa/oedo
        api_base = "http://${server}:${toString port}/v1";
      in
      {
        enable = true;
        # FIXME: This should auto-add from our llama-swap models somehow
        defaultModel = "ds-small";
        models = [
          {
            name = "ds-big";
            id = "ds-big";
            inherit api_base;
          }
          {
            name = "ds-small";
            id = "ds-small";
            inherit api_base;
          }
        ];
      };
  };
}
