{
  config,
  configVars,
  configLib,
  lib,
  ...
}:
let
  yubikeyHosts = [
    "genoa"
    "ghost"
    "gooey"
    "grief"
    "guppy"
    "gusto"
  ];
  # add my domain to each yubikey host
  yubikeyDomains = map (h: "${h}.${configVars.domain}") yubikeyHosts;
  yubikeyHostAll = yubikeyHosts ++ yubikeyDomains;
  yubikeyHostsString = lib.concatStringsSep " " yubikeyHostAll;

  pathtokeys = configLib.relativeToRoot "hosts/common/users/${configVars.username}/keys";
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
      # Remove the .pub suffix
      (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
      # list of dicts
      (key: { ".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub"; })
      yubikeys
  );

  identityFiles = [
    "id_yubikey" # This is an auto symlink to whatever yubikey is plugged in. See hosts/common/optional/yubikey
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
        host = host;
        hostname = "${host}.${configVars.domain}";
        port = configVars.networking.ports.tcp.ssh;
      };
    }) vanillaHosts
  );
in
{
  programs.ssh = {
    enable = true;

    # FIXME: This should probably be for git systems only?
    controlMaster = "auto";
    controlPath = "~/.ssh/sockets/S.%r@%h:%p";
    controlPersist = "10m";

    # req'd for enabling yubikey-agent
    extraConfig = ''
      AddKeysToAgent yes
    '';

    matchBlocks = {
      # Not all of this systems I have access to can use yubikey.
      "yubikey-hosts" = lib.hm.dag.entryAfter [ "*" ] {
        host = "${yubikeyHostsString}";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = lib.lists.forEach identityFiles (file: "${config.home.homeDirectory}/.ssh/${file}");
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
        hostname = "gooey.${configVars.domain}";
        user = "pi";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = lib.lists.forEach identityFiles (file: "${config.home.homeDirectory}/.ssh/${file}");
      };
      "oops" = lib.hm.dag.entryAfter [ "yubikey-hosts" ] {
        host = "oops";
        hostname = "${configVars.networking.subnets.oops.ip}";
        user = "${configVars.username}";
        port = configVars.networking.subnets.oops.port;
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_yubikey"
        ];
      };
      "cakes" = {
        host = "${configVars.networking.external.cakes.name}";
        hostname = "${configVars.networking.external.cakes.ip}";
        user = "${configVars.networking.external.cakes.username}";
        localForwards = [
          {
            bind.address = "localhost";
            bind.port = configVars.networking.external.cakes.localForwardsPort;
            host.address = "localhost";
            host.port = configVars.networking.external.cakes.localForwardsPort;
          }
        ];
      };
    } // vanillaHostsConfig;

  };
  home.file = {
    ".ssh/config.d/.keep".text = "# Managed by Home Manager";
    ".ssh/sockets/.keep".text = "# Managed by Home Manager";
  } // yubikeyPublicKeyEntries;
}
