# This is a module defining data to be placed inside of a microvm
#
# NOTE: Do not assume other modules/config are accessible unless
# explicitly added in the main microvm declaration in ./default.nix
#
# IMPORTANT: Seems sops doesn't work, so we inject them at runtime
# from the host

# FIXME: Break this across a few files probably
{
  inputs,
  lib,
  pkgs,
  vmSpecs,
  namespace,
  ...
}:
let
  inherit (vmSpecs)
    name
    user
    vm-lan
    sharedDir
    sshPort
    hostAuthorizedKeys
    ;

  sshKeyPath = "/run/secrets/ssh_host_ed25519_key";
in
{
  imports = [
    inputs.microvm.nixosModules.microvm
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit
          user
          inputs
          vmSpecs
          namespace
          ;
      };
      users.${user} = {
        imports = (
          map lib.custom.relativeToRoot [
            "microvms/home/common/core"
          ]
        );
      };
    };

    users = {
      mutableUsers = false;
      allowNoPasswordLogin = true;

      users.${user} = {
        isNormalUser = true;
        uid = 1000; # FIXME: Needs to be configurable? Needs to be relayed to shared folders somehow
        home = "/home/${user}";
        createHome = true;
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = hostAuthorizedKeys;
        # Secrets exposed in /run/micromv-secrets/{name} are scoped to this group
        extraGroups = [ "kvm" ];
      };

      groups.${user}.gid = 1000;
    };

    # agent has root in microvm
    security.sudo.extraRules = [
      {
        users = [ user ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    systemd.tmpfiles.rules = [
      # Required when a volume is mounted as home (see ./default.nix)
      "d /home/${user} 0755 ${user} ${user} -"
      # Secrets mirror from host sops
      "d /run/secrets  2750 root kvm -"
    ];

    # ── Fix for microvm shutdown hang (issue #170) ────────────────
    # Without this, systemd tries to unmount /nix/store during
    # shutdown but umount lives in /nix/store → deadlock.
    # From https://github.com/FintanH/fintos/blob/67dd2cf6ae7db2bab2a7dd9825f604188565f2ef/microvm/base.nix
    systemd.mounts = [
      {
        what = "store";
        where = "/nix/store";
        overrideStrategy = "asDropin";
        unitConfig.DefaultDependencies = false;
      }
    ];

    system.stateVersion = "26.05";
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    programs.zsh.enable = true;

    services.openssh = {
      enable = true;
      ports = [ sshPort ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;

        # Don't bother with rsa keys, since we are only connecting from our host
        PubkeyAcceptedAlgorithms = "ssh-ed25519";
        HostKeyAlgorithms = "ssh-ed25519";
      };
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = sshPort;
        }
      ];
      # Persist sshd host keys on a bind-mounted path so they survive
      # VM/container rebuilds and clients don't see host-key-changed warnings.
      # FIXME: Update this to use impermanence and put /persist/etc stored on the host probably?
      # See this thread: https://github.com/microvm-nix/microvm.nix/issues/52
      hostKeys = [
        {
          path = sshKeyPath;
          type = "ed25519";
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ sshPort ];

    # Basic page-cache bug hardening
    boot.blacklistedKernelModules = [
      "af_alg"
      "algif_aead"
      "algif_skcipher"
      "algif_hash"
      "algif_rng"

      "esp4"
      "esp6"
      "rxrpc"
    ];
    boot.extraModprobeConfig =
      let
        false = "${pkgs.coreutils}/bin/false";
      in
      ''
        install af_alg         ${false}
        install algif_aead     ${false}
        install algif_skcipher ${false}
        install algif_hash     ${false}
        install algif_rng      ${false}
        install authenc        ${false}
        install authencesn     ${false}

        install esp4           ${false}
        install esp6           ${false}
        install rxrpc          ${false}
      '';
    time.timeZone = "UTC";

    networking.hostName = "${name}";

    # FIXME: Make this configurable eventually
    microvm = {
      hypervisor = "qemu";
      vcpu = 2;
      mem = 4096;
      balloon = true;

      # IMPORTANT: This is needed if you want microvm cli command to work
      # when not defining microvms as stand-alone flake outputs
      systemSymlink = true;

      # Writable nix store overlay (tmpfs — ephemeral).
      writableStoreOverlay = "/nix/.rw-store";

      # Persistent volumes (stored in /var/lib/microvms/<name>/)
      # FIXME: These will need to be optional, so some microvms are ramfs only,
      # some use impermanence with disk images, etc
      volumes = [
        {
          mountPoint = "/var";
          image = "var.img";
          size = 102400; # 100 GB
        }
        {
          mountPoint = "/nix/.rw-store";
          image = "nix-store.img";
          size = 61440; # 60 GB for nix store
        }
        {
          mountPoint = "/home/${user}";
          image = "home.img";
          size = 102400; # 100 GB for home directory
        }
      ];

      # NOTE: The id is important as it correlates to the tap on the host-side.
      # If you change the tap id prefix, change the tap matching in
      # microvms/network.nix as well
      # FIXME: It should just be some option I guess
      interfaces = [
        {
          type = "tap";
          id = "microvm-${name}"; # IMPORTANT: Before changing, read the comment above
          mac = vmSpecs.mac;
        }
      ];

      shares = [
        # Host's /nix/store (avoids building a squashfs image)
        # FIXME: Blacklist some files if possible?
        # There is a wifi password in /nix/store on some systems due to initrd ssh unlock
        {
          proto = "virtiofs";
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }

        # Development folder for agent-specific projects
        {
          source = "${sharedDir}/shared/${name}";
          mountPoint = "${sharedDir}/shared/${name}";
          tag = "agent-dev";
          proto = "virtiofs";
        }
        # Shared folder used across microvms
        {
          # FIXME: This needs to switch to interVmSharedDir
          source = "${sharedDir}/agents-shared";
          mountPoint = "${sharedDir}/agents-shared";
          tag = "agent-share";
          proto = "virtiofs";
        }
        # Secrets exposed from host sops
        {
          tag = "microvm-secrets";
          source = "/run/microvm-secrets/${name}";
          mountPoint = "/run/secrets";
          proto = "virtiofs";
        }
      ];
    };

    networking.useNetworkd = true;
    networking.useDHCP = false;

    # FIXME: use dhcp? if the host is bridged through vpn, it will use
    # whatever is provided like the default VPN dns?
    systemd.network.networks."10-eth" = {
      matchConfig.MACAddress = vmSpecs.mac;
      address = [ "${vmSpecs.ip}/${toString vm-lan.prefixLength}" ];
      routes = [ { Gateway = vm-lan.gateway; } ];
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };
}
