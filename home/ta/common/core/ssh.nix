{
  config,
  inputs,
  lib,
  ...
}:
let
  # There are a subset of hosts where yubikey is used for authentication. An ssh config entry is constructed for each
  # of these hosts that roughly follows the same pattern. Some of these hosts use a domain suffix, so build a list of
  # all hosts with and without domains
  yubikeyHostsWithDomain = [
    "genoa"
    "ghost"
    "gooey"
    "grief"
    "guppy"
  ] ++ inputs.nix-secrets.networking.ssh.yubikeyHostsWithDomain;

  yubikeyHostsWithoutDomain = [
    config.hostSpec.networking.subnets.grove.wildcard
    config.hostSpec.networking.subnets.vm-lan.wildcard
  ] ++ inputs.nix-secrets.networking.ssh.yubikeyHosts;

  # Add domain to each host name
  genDomains = lib.map (h: "${h}.${config.hostSpec.domain}");
  yubikeyHostAll =
    yubikeyHostsWithDomain ++ yubikeyHostsWithoutDomain ++ (genDomains yubikeyHostsWithDomain);
  yubikeyHostsString = lib.concatStringsSep " " yubikeyHostAll;

  # Only a subset of hosts are trusted enough to allow agent forwarding
  forwardAgentHosts = lib.foldl' (acc: b: lib.filter (a: a != b) acc) yubikeyHostsWithDomain (
    [ ] ++ inputs.nix-secrets.networking.ssh.forwardAgentUntrusted
  );
  forwardAgentHostsString = lib.concatStringsSep " " (
    forwardAgentHosts ++ (genDomains forwardAgentHosts)
  );

  pathtokeys = lib.custom.relativeToRoot "hosts/common/users/primary/keys";
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
      # Remove the .pub suffix
      (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map (key: { ".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub"; }) yubikeys
  );

  identityFiles = [
    "id_yubikey" # This is an auto symlink to whatever yubikey is plugged in. See modules/common/yubikey
    "id_manu" # fallback to id_manu if yubikeys are not present
  ];

  # Lots of hosts have the same default config, so don't duplicate
  vanillaHosts = [
    "genoa"
    "ghost"
    "grief"
    "guppy"
    "gusto"
  ];
  vanillaHostsConfig = lib.attrsets.mergeAttrsList (
    lib.lists.map (host: {
      "${host}" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
        match = "host ${host},${host}.${config.hostSpec.domain}";
        hostname = "${host}.${config.hostSpec.domain}";
        port = config.hostSpec.networking.ports.tcp.ssh;
      };
    }) vanillaHosts
  );
in
{
  programs.ssh =
    let
      workConfig = if config.hostSpec.isWork then ''Include config.d/work'' else "";
    in
    {
      enable = true;

      # FIXME(ssh): This should probably be for git systems only?
      controlMaster = "auto";
      controlPath = "${config.home.homeDirectory}/.ssh/sockets/S.%r@%h:%p";
      controlPersist = "20m";
      # Avoids infinite hang if control socket connection interrupted. ex: vpn goes down/up
      serverAliveCountMax = 3;
      serverAliveInterval = 5; # 3 * 5s
      hashKnownHosts = true;
      addKeysToAgent = "yes";

      # Bring in decrypted config
      extraConfig = ''
        UpdateHostKeys ask
        ${workConfig}
      '';

      matchBlocks =
        let
          workHosts = if config.hostSpec.isWork then inputs.nix-secrets.work.git.servers else "";
        in
        {
          # Not all of this systems I have access to can use yubikey.
          "yubikey-hosts" = lib.hm.dag.entryAfter [ "*" ] {
            host = "${workHosts} ${yubikeyHostsString}";
            identitiesOnly = true;
            identityFile = lib.lists.forEach identityFiles (file: "${config.home.homeDirectory}/.ssh/${file}");
          };

          # Only forward agent to hosts that need it
          "forward-agent-hosts" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
            host = forwardAgentHostsString;
            forwardAgent = true;
          };

          "git" = {
            host = "gitlab.com github.com";
            user = "git";
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = lib.lists.forEach identityFiles (file: "${config.home.homeDirectory}/.ssh/${file}");
          };
          "gooey" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
            host = "gooey";
            hostname = "gooey.${config.hostSpec.domain}";
            user = config.hostSpec.networking.subnets.grove.hosts.gooey.user;
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = lib.lists.forEach identityFiles (file: "${config.home.homeDirectory}/.ssh/${file}");
          };
          "oops" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
            host = "oops";
            hostname = "oops.${config.hostSpec.domain}";
            user = "${config.hostSpec.username}";
            port = config.hostSpec.networking.ports.tcp.oops;
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = [
              "~/.ssh/id_yubikey"
              "~/.ssh/id_borg"
            ];
          };
        }
        // (inputs.nix-secrets.networking.ssh.matchBlocks lib)
        // vanillaHostsConfig;

    };
  home.file = {
    ".ssh/config.d/.keep".text = "# Managed by Home Manager";
    ".ssh/sockets/.keep".text = "# Managed by Home Manager";
  } // yubikeyPublicKeyEntries;
}
