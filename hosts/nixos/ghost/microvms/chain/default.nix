{
  config,
  lib,
  namespace,
  ...
}:
let
  networking = config.hostSpec.networking;
  subnets = networking.subnets;
  # ports = networking.ports;
  # llamaSwapPort = ports.tcp.llama-swap;
  # ghostLlamaSwapPort = (ports.tcp.llama-swap + 1);
  grove = subnets.grove;
  chainSpecs = rec {
    vm-lan = subnets.c-lan;
    hostAuthorizedKeys = [
      grove.hosts.${config.networking.hostName}.sshPubKey
    ];
    inherit (vm-lan.hosts.chain) ip;
    name = "chain";
    user = config.hostSpec.primaryUsername;
    mac = (lib.head vm-lan.hosts.chain.mac);
    sshPort = 22;
    sharedDir = config.${namespace}.microvms.sharedDir;
    # allowedPorts = {
    #   # Expose local llama-swap for use by agents
    #   tcp = [
    #     llamaSwapPort
    #   ];
    # };

    # Some service stuff needs synced ports, so we need to expose it
    ports = config.hostSpec.networking.ports;
  };
in
{
  imports = [
    # Anonymous submodule to allow us to specify an isolated vmSpecs
    {
      _module.args.vmSpecs = chainSpecs;
      imports = [ (lib.custom.relativeToRoot "modules/hosts/nixos/microvms/agents.nix") ];
    }
  ];

  microvm.vms.chain = {
    specialArgs = {
      vmSpecs = chainSpecs;
    };
    config = {
      imports = [
        (lib.custom.relativeToRoot "microvms/hosts/common/optional/agents.nix")
      ];
      home-manager = {
        # FIXME(microvms): This would need to change if we want multiple users
        users.${chainSpecs.user} = {
          imports = [ ./home.nix ];
        };
      };
    };
  };

  ${namespace}.microvms = {
    vpn.enable = true;
  };

  # Setup some custom rules for forwarding to ghost llama-swap
  networking.nftables.ruleset =
    let
      inherit (config.${namespace}.microvms) vmBridge;
    in
    ''
      table inet vm_routing {

        chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
        }

        chain forward {
          iifname "${vmBridge}" ip daddr ${grove.hosts.ghost.ip} accept
        }

        chain postrouting {
          ip daddr ${grove.hosts.ghost.ip} masquerade
        }
      }
    '';

  # This needs to be injected because for now we manually forward a port
  # to ghost, so it needs to not route it over vm-vpn. Priority must be below
  # the vm-vpn entry in modules/hosts/nixos/microvms/network.nix
  # FIXME: This needs to keep in sync with the id in the file above, so could use an option
  systemd.network.networks."20-${config.${namespace}.microvms.vmBridge}" = {
    routingPolicyRules = [
      {
        From = config.${namespace}.microvms.vmLan.cidr;
        To = grove.cidr;
        Table = "main";
        Priority = 998;
      }
    ];
  };
}
