{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 2049 ];

  services.nfs.server = {
    enable = true;
    exports =
      let
        gustoIP = config.hostSpec.networking.subnets.grove.hosts.gusto.ip;
        genoaIP = config.hostSpec.networking.subnets.grove.hosts.genoa.ip;
        genoaGladeIP = config.hostSpec.networking.subnets.glade.hosts.genoa.ip;
        options = "rw,sync,no_subtree_check";
      in
      ''
        /mnt/media1/mediashare ${gustoIP}/24(${options}) ${genoaIP}/24(${options}) ${genoaGladeIP}/24(${options})
      '';
  };
}
