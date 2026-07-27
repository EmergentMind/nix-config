# home level sops. see hosts/common/optional/sops.nix for hosts level
{
  inputs,
  config,
  osConfig,
  lib,
  ...
}:
let
  sopsFolder = (lib.toString inputs.nix-secrets) + "/sops";
  homeDirectory = config.home.homeDirectory;
  # FIXME(yubikey): move this, u2f sops extraction, and other yubi stuff to be set as yubikey module options
  # so it doesn't doesn't interfere with bootstrapping
  yubikeys = [
    "maya"
    "mara"
    "manu"
  ];
  yubikeySecrets =
    # extract to default pam-u2f authfile location for passwordless sudo. see modules/hosts/common/yubikey
    lib.optionalAttrs osConfig.hostSpec.useYubikey (
      {
        "keys/u2f" = {
          sopsFile = "${sopsFolder}/shared.yaml";
          path = "${homeDirectory}/.config/Yubico/u2f_keys";
        };
      }
      // lib.attrsets.mergeAttrsList (
        lib.lists.map (name: {
          "keys/ssh/${name}" = {
            sopsFile = "${sopsFolder}/shared.yaml";
            path = "${homeDirectory}/.ssh/id_${name}";
          };
        }) yubikeys
      )
    );
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops = {
    # This is the location of the host specific age-key for ta and will to have been extracted to this location via hosts/common/core/sops.nix on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${sopsFolder}/${osConfig.hostSpec.hostName}.yaml";
    validateSopsFiles = false;

    secrets = {
      # formatted as extra-access-tokens = github.com=<PAT token>
      "tokens/nix-access-tokens" = {
        sopsFile = "${sopsFolder}/shared.yaml";
      };
    }
    // lib.optionalAttrs osConfig.hostSpec.isDevelopment {
      # LLM tokens, use agents.yaml since it's shared elsewhere
      # FIXME: This should be automated and synced with other usages in config
      "tokens/openai" = {
        sopsFile = "${sopsFolder}/agents.yaml";
      };
      "tokens/anthropic" = {
        sopsFile = "${sopsFolder}/agents.yaml";
      };
      "tokens/google" = {
        sopsFile = "${sopsFolder}/agents.yaml";
      };
      "tokens/deepseek" = {
        sopsFile = "${sopsFolder}/agents.yaml";
      };
    }
    // yubikeySecrets;
  };
}
