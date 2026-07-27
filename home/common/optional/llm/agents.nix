# NOTE: This is used by microvms, so don't add anything too wacko
{
  pkgs,
  lib,
  ...
}:
{
  home = {
    packages = lib.attrValues {
      inherit (pkgs)
        claude-code
        claude-agent-acp
        codex
        codex-acp
        crush
        gemini-cli
        pi-coding-agent
        ;
    };
  };
}
