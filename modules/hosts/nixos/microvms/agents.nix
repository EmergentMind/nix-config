# microvm-related host configuration for agent vms
{
  lib,
  inputs,
  config,
  vmSpecs,
  ...
}:
let
  sopsFolder = (lib.toString inputs.nix-secrets) + "/sops";
  tokens = [
    "anthropic"
    "openai"
    "google"
    "deepseek"
  ];
in
{
  sops.secrets =
    tokens
    |> map (name: {
      "tokens/${name}" = {
        sopsFile = "${sopsFolder}/agents.yaml";
        group = "kvm";
        mode = "0440";
      };
    })
    |> lib.mergeAttrsList;

  # This service copies secrets directly into a ramfs on the microvm
  # See ./default for why
  systemd.services.microvm-prepare-agent-secrets = {
    description = "Stage SOPS agent secrets for microVM";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    # NOTE: ./default systemd.tmpfiles.rules already handled /run/microvm-secrets/${name} creation
    script =
      tokens
      |> map (token:
      # bash
      ''
        cp --remove-destination ${
          config.sops.secrets."tokens/${token}".path
        } /run/microvm-secrets/${vmSpecs.name}/${token}_api_key
        chgrp kvm /run/microvm-secrets/${vmSpecs.name}/${token}_api_key
      '')
      |> lib.concatStringsSep "\n";
  };
}
