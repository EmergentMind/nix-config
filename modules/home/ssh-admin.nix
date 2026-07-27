# FIXME(roles): This eventually should get slotted into some sort of 'role' thing
{
  osConfig,
  lib,
  secrets,
  ...
}:
let
  cfg = osConfig.hostSpec;
in
lib.mkIf cfg.isAdmin {
  sshAutoEntries = {
    enable = true;
    defaultUser = "ta";
    ykDomainHosts = [
      "genoa"
      "ghost"
      "gooey" # confirm
      "grief"
      "guppy"
      "gusto"
    ];
    ykNoDomainHosts = [
      "myth"
      cfg.networking.subnets.glade.wildcard
      cfg.networking.subnets.grove.wildcard
      cfg.networking.subnets.c-lan.wildcard
    ]
    ++ lib.optional cfg.isWork secrets.work.git.servers;
  };
  programs.ssh.settings =
    let
      # ===== non-nixos hosts on internal subnets =====

      # TODO:
      # gladeSubnetHosts= [
      # ];
      groveSubnetHosts = [
        "glass"
        "gooey"
        "guard"
      ];
      extraSubnetEntries =
        hosts: subnet:
        hosts
        |> lib.lists.map (host: {
          "${host}" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
            Match = "host ${host},${host}.${cfg.domain}";
            HostName = "${host}.${cfg.domain}";
            User = cfg.networking.subnets.${subnet}.hosts.${host}.user;
            Port = cfg.networking.subnets.${subnet}.hosts.${host}.sshPort;
          };
        })
        |> lib.attrsets.mergeAttrsList;
    in
    {
      # external hosts with
      "moth" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
        Host = "moth";
        HostName = "moth.${cfg.domain}";
        User = "${cfg.primaryUsername}";
        Port = cfg.networking.ports.tcp.moth;
      };
      # "myth" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
      #   Host = "myth ${secrets.networking.domains.myth}";
      #   HostName = "${secrets.networking.domains.myth}";
      #   User = "admin";
      #   Port = cfg.networking.ports.tcp.myth;
      # };
    }
    # // (extraSubnetEntries gladeSubnetHosts "glade")
    // (extraSubnetEntries groveSubnetHosts "grove");
}
