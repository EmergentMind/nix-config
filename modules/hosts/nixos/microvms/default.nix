# WIP module for setting up microvms, currently geared towards agents
# but slowly migrating towards being more generic
#
# Inspiration from:
# https://github.com/jasonodoom/nixos-configs/blob/17b43a1/framework-desktop/modules/ai-microvms.nix
# https://github.com/FintanH/fintos/blob/67dd2c/microvm/base.nix

{
  config,
  pkgs,
  lib,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.microvms;
  user = config.hostSpec.primaryUsername;
in
{
  # NOTE: See ./vpn.nix for additional sub option
  options.${namespace}.microvms = {
    # Base directory for:
    # 1) data shared with only this microvm: ${sharedDir}/shared/<vm-name>/
    # 2) data shared across microvms ${sharedDir}/vms-shared/
    sharedDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${user}/dev/ai/";
      description = "Base folder used for sharing folders with a given microvm";
    };
    interVmSharedDir = lib.mkOption {
      type = lib.types.str;
      default = "vms-shared";
      description = "Folder name inside ${
        config.${namespace}.microvms.sharedDir
      } where all VMs have a shared folder";
    };

    # FIXME: Eventually if we have microvms across networks, this will have to
    # get rethought
    vmBridge = lib.mkOption {
      type = lib.types.str;
      default = "vbr-microvms";
      description = "Name of the virtual bridge used for the microvm network";
    };
    vmLan = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "The attrset describing the network the microvms live on";
    };
  };

  imports = [
    inputs.microvm.nixosModules.host
    ./network.nix
    ./vpn.nix
  ];

  config = lib.mkIf (lib.length (lib.attrNames config.microvm.vms) != 0) {

    systemd.tmpfiles.rules = [
      "d ${cfg.sharedDir}               0750 ${config.hostSpec.primaryUsername} users -"
      "d ${cfg.sharedDir}/shared        0750 ${config.hostSpec.primaryUsername} users -"
      "d ${cfg.sharedDir}/${cfg.interVmSharedDir} 0750 1000 1000 -"
    ]
    ++ (
      config.microvm.vms
      |> lib.attrNames
      |> map (name: [
        "d ${cfg.sharedDir}/shared/${name}      0750 ${config.hostSpec.primaryUsername} users -"
        "d /run/microvm-secrets/        0750 root  kvm   -"
        "d /run/microvm-secrets/${name} 0750 root  kvm   -"
      ])
      |> lib.flatten
    );

    # IMPORTANT: It seems templates don't work. You can set path to point
    # into a folder mounted into the VM, but it will still symlink into
    # /run/secrets/rendered/ and that folder won't actually exist on the VM
    sops.secrets = (
      config.microvm.vms
      |> lib.attrNames
      |> lib.map (name: {
        "microvms/keys/ssh/${name}" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      })
      |> lib.mergeAttrsList
    );

    # The secrets defined above won't be directly accessible in the virtiofs share
    # if placed with .path, because they are a symlink. So this service copies
    # the contents directly
    systemd.services.microvm-prepare-secrets = {
      description = "Stage SOPS secrets for microVM";
      wantedBy = [ "multi-user.target" ];
      after = [ "sops-nix.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      # systemd.tmpfiles.rules already handled dir creation
      script =
        config.microvm.vms
        |> lib.attrNames
        |> lib.map (name:
        # bash
        ''
          cp --remove-destination ${
            config.sops.secrets."microvms/keys/ssh/${name}".path
          } /run/microvm-secrets/${name}/ssh_host_ed25519_key
        '')
        |> lib.concatStringsSep "\n";
    };

    environment = {
      systemPackages = [ inputs.microvm.packages.${pkgs.stdenv.hostPlatform.system}.microvm ];
    }
    // lib.optionalAttrs config.introdus.impermanence.enable {
      persistence.${config.hostSpec.persistFolder}.directories =
        lib.mkIf config.introdus.impermanence.enable
          [
            config.microvm.stateDir
          ];
    };
  };
}
