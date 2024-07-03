{
  pkgs,
  inputs,
  config,
  lib,
  configVars,
  ...
}:
let
  cfg = config.system.impermanence;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.system.impermanence = with lib.types; {
    enable = lib.mkOption {
      type = bool;
      default = false;
      description = "Enable impermanence";
    };
    # FIXME: Actually use this in the script, but need to use the substituteAll approach
    removeTmpFilesOlderThan = lib.mkOption {
      type = int;
      default = 14;
      description = "Number of days to keep old btrfs_tmp files";
    };
  };

  # FIXME: Revisit this, as I don't use it atm
  options.environment = with lib.types; {
    persist = lib.mkOption {
      type = attrs;
      default = { };
      description = "Files and directories to persist in the home";
    };
  };

  # FIXME: Indicate the subvolume to backup
  config = lib.mkIf cfg.enable (
    let
      btrfs-diff = pkgs.writeShellApplication {
        name = "btrfs-diff";
        runtimeInputs = with pkgs; [
          eza
          fd
          btrfs-progs
        ];
        text = builtins.readFile ./btrfs-diff.sh;
      };
    in
    {
      # NOTE: With boot.initrd.systemd.enable = true, we can't use boot.initrd.postDeviceCommands as per
      # https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167
      # So we build an early stage systemd service, which is modeled after
      # https://github.com/kjhoerr/dotfiles/blob/trunk/.config/nixos/os/persist.nix
      # boot.initrd.postDeviceCommands = lib.mkAfter (lib.readFile ./btrfs_wipe_root.sh);
      # Also see https://github.com/Misterio77/nix-config/blob/main/hosts/common/optional/ephemeral-btrfs.nix
      boot.initrd =
        let
          hostname = config.networking.hostName;
          btrfs-subvolume-wipe-src = lib.readFile ./btrfs-wipe-root.sh;
        in
        {
          supportedFilesystems = [ "btrfs" ];
          systemd.services.btrfs-rollback = {
            description = "Rollback BTRFS root subvolume to a pristine state";
            wantedBy = [ "initrd.target" ];
            after = [
              "dev-mapper-encrypted\\x2dnixos.device"
              # LUKS/TPM process
              "systemd-cryptsetup@${hostname}.service"
            ];
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = btrfs-subvolume-wipe-src;
          };
        };

      fileSystems."${configVars.persistFolder}".neededForBoot = true;

      # NOTE: This is a list of directories and files that we want to persist across reboots for all systems
      # per-system lists are provided in hosts/<host>/
      environment.persistence."${configVars.persistFolder}" = {
        hideMounts = true; # Temporary disable for debugging
        directories = [
          "/var/log"
          "/var/lib/bluetooth" # move to bluetooth-specific
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
        ];
        files = [
          # Essential. If you don't have these for basic setup, you will have a bad time
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"

          # Non-essential
          "/root/.ssh/known_hosts"
        ];
      };

      programs.fuse.userAllowOther = true;

      environment.systemPackages = [ btrfs-diff ];
    }
  );
}
