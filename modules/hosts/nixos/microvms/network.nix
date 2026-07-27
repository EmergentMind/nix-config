{
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.microvms;
  vm-lan = cfg.vmLan;
  vmBridge = cfg.vmBridge;
  vpnCfg = cfg.vpn;
in
{
  config = lib.mkIf (lib.length (lib.attrNames config.microvm.vms) != 0) {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = lib.mkForce 1;
      "net.ipv6.conf.all.forwarding" = lib.mkForce 1;
    };

    systemd.network = {
      enable = true;
      wait-online.enable = false;

      # Bridge device for microvms back to host
      netdevs."20-${vmBridge}".netdevConfig = {
        Kind = "bridge";
        Name = vmBridge;
      };

      networks."20-${vmBridge}" = {
        matchConfig.Name = vmBridge;
        addresses = [ { Address = "${vm-lan.gateway}/${toString vm-lan.prefixLength}"; } ];
        networkConfig.ConfigureWithoutCarrier = true;

        routingPolicyRules = [
          # Allow access between the guest and the host
          {
            From = vm-lan.cidr;
            To = vm-lan.cidr;
            Table = "main";
            Priority = 999;
          }
          # Route everything else over VPN if enabled
          # FIXME: This could move to vpn.nix, but then we'd need to track/sync the rule name
          (lib.optionalAttrs cfg.vpn.enable {
            From = vm-lan.cidr;
            Table = vpnCfg.tableNum;
            Priority = 1000;
          })
        ];
      };

      # Creates a tap between vbr-microvms and all vms that follow the microvm-*
      # naming pattern
      networks."21-${vmBridge}-tap" = {
        matchConfig.Name = "microvm-*"; # NOTE: Corresponds to microvms/common/core/default.nix's microvms.interfaces
        networkConfig.Bridge = vmBridge;
      };
    };

    # Outbound NAT only for packets going out the proton vpn
    # Allow established traffic for host -> microvm ssh session
    networking.nftables =
      let
        # Add all of the allowed tcp/udp ports for a given VM to the host
        # FIXME: What if a compromised VM maliciously changes it's ip?
        vms = config.microvm.vms;
        genAllowedInputs =
          vms
          |> lib.attrNames
          |> map (
            name:
            let
              specs = vms.${name}.specialArgs.vmSpecs;
            in
            if (specs ? allowedPorts) then
              map (
                proto:
                map (port: ''
                  #iifname "${vmBridge}" ip saddr ${specs.ip} ether saddr ${specs.mac} ${proto} dport ${toString port} accept
                  iifname "${vmBridge}" ip saddr ${specs.ip} ${proto} dport ${toString port} accept
                '') specs.allowedPorts.${proto}
              ) (lib.attrNames specs.allowedPorts)
            else
              ""
          )
          |> lib.flatten
          |> lib.concatStringsSep "\n";
      in
      {
        enable = true;
        # FIXME: The vm_routing part should only be added for vpn in vpn.nix?
        ruleset = ''
          table inet nixos-fw {
            chain input-allow {
              ${genAllowedInputs}
            }
          }

          table inet vm_routing {
            chain output {
              type filter hook output priority filter;
              oifname "${vmBridge}" accept
            }

            chain forward {
              type filter hook forward priority filter; policy drop;

              # Allow established internet traffic back to the VM
              ct state established,related accept

              # Allow the VM to route outbound traffic to the VPN interface
              iifname "${vmBridge}" oifname "${vpnCfg.ifname}" accept
            }

            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;
              oifname "${vpnCfg.ifname}" masquerade
            }
          }
        '';
      };
  };
}
