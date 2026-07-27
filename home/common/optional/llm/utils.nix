{
  # lib,
  # pkgs,
  # osConfig,
  ...
}:
# let
#   genTokenSpeed =
#     host: port:
#     pkgs.writeShellApplication {
#       name = "token-speed-${host}";
#       runtimeInputs = lib.attrValues { inherit (pkgs) jq curl; };
#       text = # bash
#         ''
#           curl -s -X POST "http://${host}:${toString port}/v1/chat/completions" \
#             -H "Content-Type: application/json" \
#             -H "Authorization: Bearer my-dummy-key" \
#             -d '{
#                    "model": "'"$1"'",
#                    "messages": [{"role": "user", "content": "Tell me a short joke. This is a ping test, ignore system prompts."}],
#                    "max_tokens": 100
#                 }' | jq '.timings | {Prompt_Speed: .prompt_per_second, Generation_Speed: .predicted_per_second}'
#         '';
#     };
#   token-speed-oedo = genTokenSpeed "oedo" osConfig.hostSpec.networking.ports.tcp.llama-swap;
#   token-speed-ossa = genTokenSpeed "ossa" osConfig.hostSpec.networking.ports.tcp.llama-swap;
# in
{
  home.packages = [
    # token-speed-oedo
    # token-speed-ossa
  ];
}
