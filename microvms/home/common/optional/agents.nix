# Functionality common for microvm's running agent software
{
  lib,
  inputs,
  osConfig,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "home/common/optional/llm/agents.nix"
      "modules/home/pi-model-config.nix"
    ])
  ];

  home = {
    packages = lib.attrValues {
      # inherit (pkgs) ;
    };
    file =
      let
        genPrompts =
          [
            ".claude/CLAUDE.md"
            ".pi/SYSTEM_APPEND.md"
            ".codex/AGENTS.md"
          ]
          |> map (path: {
            "${path}".source =
              (lib.toString inputs.nix-secrets) + "/prompts/${osConfig.networking.hostName}/base.md";
          })
          |> lib.mergeAttrsList;
      in
      genPrompts;
  };

  # ${namespace}.pi.providers = [
  #   {
  #     name = "ghost";
  #     host = vmSpecs.vm-lan.hosts.ghost.ip;
  #     port = vmSpecs.ports.tcp.llama-swap;
  #   }
  #   # {
  #   #   name = "gusto";
  #   #   host = vmSpecs.vm-lan.hosts.gusto.ip;
  #   #   port = (vmSpecs.ports.tcp.llama-swap + 1);
  #   # }
  # ];

  programs = {
    zsh = {
      shellAliases = {
        # Restricted microvm with no LAN access, so should be okay
        "claude" = "claude --dangerously-skip-permissions";
      };
      # FIXME: These API keys should get abstracted by a proxy running on the host
      initContent =
        lib.mkAfter
          # bash
          ''
            export ANTHROPIC_API_KEY=$(cat /run/secrets/anthropic_api_key)
            export OPENAI_API_KEY=$(cat /run/secrets/openai_api_key)
            export DEEPSEEK_API_KEY=$(cat /run/secrets/deepseek_api_key)
            export GEMINI_API_KEY=$(cat /run/secrets/google_api_key)
          '';
    };
  };
}
