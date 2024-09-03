# This module uses the pkgs.borgbackup package but adds modularity
# TODO decouple this to make it config agnostic so it can be published upstream
{
  pkgs,
  lib,
  config,
  configVars,
  configLib,
  ...
}:
let
  cfg = config.services.backup;
  homeDirectory =
    if pkgs.stdenv.isLinux then "/home/${configVars.username}" else "/Users/${configVars.username}";
  excludes = [
    # Root folders, these only matter on non-impermanence systems
    "/dev"
    "/proc"
    "/sys"
    "/var/run"
    "/run"
    "/lost+found"
    "/mnt"
    # Common home cache files/directories
    "*.pyc"
    "/home/*/.direnv"
    "/home/*/.cache"
    "/home/*/.npm"
    "/home/*/.npm-global"
    "/home/*/.node-gyp"
    "/home/*/.yarn"
    "/home/*/.pnpm-store"
    "/home/*/.m2"
    "/home/*/.gradle"
    "/home/*/.opam"
    "/home/*/.clangd"
    "/home/*/.mozilla/firefox/*/storage"
    "/home/*/Android"
    "/home/*/mount"
    "/home/*/mnt"
    "/home/*/.cursorless"
    # Rust
    "/home/*/.cargo/"
    "/home/*/.rustup"
    "/home/*/target" # FIXME(borg): This might be too aggressive
    # Go
    "/home/*/go/pkg"
    # Lua
    "/home/*/.luarocks"
    # Nix
    "/home/*/result"
    # FIXME(borg): To double check
    "/var/lib/lxcfs"
    # System cache files/directories
    "/var/lib/containerd"
    "/var/lib/docker/"
    "/var/lib/systemd"
    "/var/cache"
    "/var/tmp"
  ];
  borgExcludesFile = pkgs.writeText "borg-excludes" (
    lib.concatMapStrings (s: s + "\n") (excludes ++ cfg.borgExcludes)
  );
in
{
  imports = [ (configLib.relativeToRoot "hosts/common/optional/msmtp.nix") ];
  options.services.backup = with lib.types; {
    enable = lib.mkEnableOption "Enable borg-based backup service";
    borgUser = lib.mkOption {
      type = str;
      default = "borg";
      description = "The user to run the borg backup as";
    };
    borgServer = lib.mkOption {
      type = str;
      default = "";
      description = "The borg server to backup to";
    };
    borgPort = lib.mkOption {
      type = str; # FIXME: int?
      default = "${builtins.toString configVars.networkign.sshPort}";
      description = "The ssh port to use for the borg server";
    };
    borgBackupPath = lib.mkOption {
      type = str;
      default = "/volume1/backups";
      description = "The path on the borg server to store backups";
    };
    borgSshKey = lib.mkOption {
      type = str;
      default = "/root/.ssh/id_borg";
      description = "The ssh key to use for borg";
    };
    borgRemotePath = lib.mkOption {
      type = str;
      default = "/usr/local/bin/borg";
      description = "The borg binary path on the borg server";
    };
    borgMountDir = lib.mkOption {
      type = str;
      default = "${homeDirectory}/mount/backup";
      description = "The directory to mount backups to";
    };
    borgCacheDir =
      let
        persistFolder = lib.optionalString config.system.impermanence.enable configVars.persistFolder;
      in
      lib.mkOption {
        type = str;
        default = "${persistFolder}/.cache/borg";
        description = "The cache directory for borg";
      };
    borgBackupPaths = lib.mkOption {
      type = listOf str;
      default = [ "${homeDirectory}" ];
      description = "The paths on host to backup";
    };
    borgBackupName = lib.mkOption {
      type = str;
      default = "${config.networking.hostName}-$(date +%Y-%m-%d_%H-%M)";
      description = "The name of the backup";
    };
    borgBtrfsVolume = lib.mkOption {
      type = str;
      default = "/dev/mapper/encrypted-nixos";
      description = "The btrfs volume containing the subvolume backup";
    };
    # FIXME: This should be a list of subvolumes to backup
    borgBtrfsSubvolume = lib.mkOption {
      type = str;
      default = "@persist";
      description = "The btrfs subvolume to mount and backup";
    };
    borgBackupExpiryDaily = lib.mkOption {
      type = int;
      default = 7;
      description = "The number of daily backups to keep";
    };
    borgBackupExpiryWeekly = lib.mkOption {
      type = int;
      default = 4;
      description = "The number of weekly backups to keep";
    };
    borgBackupExpiryMonthly = lib.mkOption {
      type = int;
      default = 6;
      description = "The number of monthly backups to keep";
    };
    borgBackupExpiryYearly = lib.mkOption {
      type = int;
      default = 3;
      description = "The number of yearly backups to keep";
    };
    borgBackupStartTime = lib.mkOption {
      type = str;
      default = "00:00:00";
      description = "The time to start the backup";
    };
    borgBackupLogPath = lib.mkOption {
      type = str;
      default = "/root/backup.log";
      description = "The log location for the backup";
    };
    # Some of these shouldn't even be options probably? Just always exclude them, but allow for custom ones
    borgExcludes = lib.mkOption {
      type = listOf str;
      default = [ ];
      description = "A list of extra paths to exclude from the backup";
    };
  };
  config = lib.mkIf cfg.enable (
    let
      shellScriptHelpers = builtins.readFile ./backup-helpers.sh;
      shellScriptOptionHandling = ''
        BORG_USER="''${BORG_USER:-${cfg.borgUser}}"
        BORG_SERVER="''${BORG_SERVER:-${cfg.borgServer}}"
        BORG_PORT="''${BORG_PORT:-${cfg.borgPort}}"
        BORG_HOST="''${BORG_HOST:-${config.networking.hostName}}"
        BORG_REMOTE_REPO="''$BORG_SERVER:''${BORG_REMOTE_REPO:-${cfg.borgBackupPath}/$BORG_HOST}"
        BORG_SSH_KEY="''${BORG_SSH_KEY:-${cfg.borgSshKey}}"
        BORG_REMOTE_PATH="''${BORG_REMOTE_PATH:---remote-path ${cfg.borgRemotePath}}"
        BORG_BACKUP_NAME="''${BORG_BACKUP_NAME:-${cfg.borgBackupName}}"
        # Export variables not used directly in script, or only used in some scripts
        export BORG_BTRFS_VOLUME="''${BORG_BTRFS_VOLUME:-${cfg.borgBtrfsVolume}}"
        export BORG_BTRFS_SUBVOLUME="''${BORG_BTRFS_SUBVOLUME:-${cfg.borgBtrfsSubvolume}}"
        export BORG_PASSPHRASE="''${BORG_PASSPHRASE:-$(cat /etc/borg/passphrase)}"
        export BORG_RSH="ssh -i $BORG_SSH_KEY -l$BORG_USER -oport=$BORG_PORT"
        export BORG_EXPIRY="--keep-daily=${builtins.toString cfg.borgBackupExpiryDaily} \
          --keep-weekly=${builtins.toString cfg.borgBackupExpiryWeekly} \
          --keep-monthly=${builtins.toString cfg.borgBackupExpiryMonthly} \
          --keep-yearly=${builtins.toString cfg.borgBackupExpiryYearly}"
        export BORG_CACHE_DIR="''${BORG_CACHE_DIR:-${cfg.borgCacheDir}}"
        if [ ! -d "$BORG_CACHE_DIR" ]; then
          mkdir -p "$BORG_CACHE_DIR"
        fi
        # Non-variable options
        export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes
        export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
      '';
      shellScriptEmail = ''
        function email_results() {
          TMPDIR=$(mktemp -d)
          cat >"$TMPDIR"/backup-mail.txt <<-EOF
        From:box@${configVars.domain}
        Subject: [${config.networking.hostName}] $(date) Backup
        $(cat "$LOGFILE")
        EOF
          msmtp -t admin@${configVars.domain} <"$TMPDIR"/backup-mail.txt
        }
      '';
      borg-backup-test-email = pkgs.writeShellApplication {
        name = "borg-backup-test-email";
        runtimeInputs = [ pkgs.msmtp ];
        text = ''
          TOOL_DESCRIPTION="Test borg script email sending function"
          ${shellScriptHelpers}
          ${shellScriptEmail}
          LOGFILE=$(mktemp)
          echo "Test backup from $(hostname)" >"$LOGFILE"
          email_results
        '';
      };
      borg-backup-btrfs-subvolume = pkgs.writeShellApplication {
        name = "borg-backup-btrfs-subvolume";
        runtimeInputs = [
          pkgs.borgbackup
          pkgs.nettools
          pkgs.mount
          pkgs.umount
          pkgs.msmtp
        ];
        text = ''
          TOOL_DESCRIPTION="Use borg to backup a btrfs subvolume"
          ${shellScriptOptionHandling}
          ${shellScriptHelpers}
          ${shellScriptEmail}
          parse_args "0" "$@"
          MOUNTDIR=$(mktemp -d)
          mount -t btrfs -o subvol=/ "$BORG_BTRFS_VOLUME" "$MOUNTDIR"
          BACKUP_PATH="$MOUNTDIR/$BORG_BTRFS_SUBVOLUME"
          # Borg doesn't let you specify the source parent folder that you want to recover, we enter the temp folder to
          # prevent it from showing up while doing recoveries
          cd "$BACKUP_PATH"
          #shellcheck disable=SC2086
          if borg create $BORG_REMOTE_PATH -v --stats --exclude-caches "$BORG_REMOTE_REPO::$BORG_BACKUP_NAME" $PWD \
            --exclude-from ${borgExcludesFile}; then
            # NOTE: --glob-archives works like a tag, so we can rename pinned backups with a none matching prefix like pinned-...
            borg prune $BORG_REMOTE_PATH -v --list "$BORG_REMOTE_REPO" --glob-archives "$BORG_HOST-*" $BORG_EXPIRY
          fi
          cd -
          umount "$MOUNTDIR"
        '';
      };
      borg-backup-paths =
        let
          backupPaths = lib.concatStringsSep " " cfg.borgBackupPaths;
        in
        pkgs.writeShellApplication {
          name = "borg-backup-paths";
          runtimeInputs = [
            pkgs.borgbackup
            pkgs.msmtp
          ];
          text = ''
            TOOL_DESCRIPTION="Use borg to backup a list of paths"
            ${shellScriptOptionHandling}
            ${shellScriptHelpers}
            ${shellScriptEmail}
            parse_args "0" "$@"
            LOGFILE="${cfg.borgBackupLogPath}"
            function borg_backup() {
                # samba mounts that we want to exclude from the backup
                MOUNT_EXCLUDES=()
                for MOUNT in $(mount | grep -i cifs | cut -d" " -f3); do
                    MOUNT_EXCLUDES+=("--exclude $MOUNT")
                done
                #shellcheck disable=SC2096,SC2068,SC2086
                if borg create $BORG_REMOTE_PATH -v --stats --exclude-caches "$BORG_REMOTE_REPO::$BORG_BACKUP_NAME" \
                  ${backupPaths} \
                  --exclude-from ${borgExcludesFile} \
                  ''${MOUNT_EXCLUDES[@]}; then
                  borg prune $BORG_REMOTE_PATH -v --list "$BORG_REMOTE_REPO" --glob-archives "$BORG_HOST-*" $BORG_EXPIRY
                fi
              }
            borg_backup >$LOGFILE 2>&1
            email_results
          '';
        };
      borg-backup-mount = pkgs.writeShellApplication {
        name = "borg-backup-mount";
        runtimeInputs = [ pkgs.borgbackup ];
        text = ''
          TOOL_DESCRIPTION="Mount a specified backup to a local directory"
          USAGE="<backup_name>"
          ${shellScriptOptionHandling}
          ${shellScriptHelpers}
          parse_args "1" "$@"
          backup_name="''${POSITIONAL_ARGS[0]}"
          BORG_MOUNT_PATH="''${BORG_MOUNT_PATH:-${cfg.borgMountDir}/$BORG_HOST}/"
          if [ ! -d "$BORG_MOUNT_PATH" ]; then
            mkdir -p "$BORG_MOUNT_PATH"
            echo "Created missing mount directory $BORG_MOUNT_PATH"
          fi
          #shellcheck disable=SC2086
          borg mount $BORG_REMOTE_PATH -v "$BORG_REMOTE_REPO"::"$backup_name" "$BORG_MOUNT_PATH"
          echo "Backup mounted at $BORG_MOUNT_PATH"
        '';
      };
      borg-backup-list = pkgs.writeShellApplication {
        name = "borg-backup-list";
        runtimeInputs = [ pkgs.borgbackup ];
        text = ''
          TOOL_DESCRIPTION="List borg backups"
          ${shellScriptOptionHandling}
          ${shellScriptHelpers}
          parse_args "0" "$@"
          #shellcheck disable=SC2086
          borg list $BORG_REMOTE_PATH $BORG_REMOTE_REPO
        '';
      };
      borg-backup-rename = pkgs.writeShellApplication {
        name = "borg-backup-rename";
        runtimeInputs = [ pkgs.borgbackup ];
        text = ''
          TOOL_DESCRIPTION="List borg backups"
          USAGE="<backup_name> <new_name>"
          ${shellScriptOptionHandling}
          ${shellScriptHelpers}
          parse_args "2" "$@"
          backup_name="''${POSITIONAL_ARGS[0]}"
          new_name="''${POSITIONAL_ARGS[1]}"
          #shellcheck disable=SC2086
          borg rename $BORG_REMOTE_PATH -v "$BORG_REMOTE_REPO"::"$backup_name" "$new_name"
          echo "Renamed backup $backup_name with new_name $new_name"
        '';
      };
      borg-backup-delete = pkgs.writeShellApplication {
        name = "borg-backup-delete";
        runtimeInputs = [ pkgs.borgbackup ];
        text = ''
          TOOL_DESCRIPTION="Delete a borg backup"
          USAGE="<backup_name>"
          ${shellScriptOptionHandling}
          ${shellScriptHelpers}
          parse_args "1" "$@"
          backup_name="''${POSITIONAL_ARGS[0]}"
          #shellcheck disable=SC2086,SC2068
          borg delete --dry-run $BORG_REMOTE_PATH -v --list \
            "$BORG_REMOTE_REPO"::"$backup_name" \
            ''${POSITIONAL_ARGS[@]:1:''${#POSITIONAL_ARGS[@]}-1}
          echo "Deleted backup $backup_name"
        '';
      };
      borg-backup-restore = pkgs.writeShellApplication {
        name = "borg-backup-restore";
        runtimeInputs = [ pkgs.borgbackup ];
        text = ''
          TOOL_DESCRIPTION="Restore from a borg backup"
          USAGE="<backup_name> <restore_path>"
          ${shellScriptOptionHandling}
          ${shellScriptHelpers}
          parse_args "2" "$@"
          backup_name="''${POSITIONAL_ARGS[0]}"
          restore_path="''${POSITIONAL_ARGS[1]}"
          #shellcheck disable=SC2086,SC2068
          borg extract $BORG_REMOTE_PATH -v \
            "$BORG_REMOTE_REPO"::"$backup_name" \
            --strip-components 1 -p "$restore_path" \
            --list \
            ''${POSITIONAL_ARGS[@]:2:''${#POSITIONAL_ARGS[@]}-1}
          echo "Restored backup $backup_name to $restore_path"
        '';
      };
    in
    {
      systemd =
        let
          serviceName =
            if config.system.impermanence.enable then "borg-backup-btrfs-subvolume" else "borg-backup-paths";
          serviceEntries = {
            services."borg-backup" = {
              description = "Run ${serviceName} to backup system";
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];
              restartIfChanged = false;
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${serviceName}";
                RemainAfterExit = false;
              };
            };
            timers."borg-backup" = {
              description = "${serviceName} backup service";
              wantedBy = [ "timers.target" ];
              after = [ "network-online.target" ];
              timerConfig = {
                OnCalendar = "*-*-* ${cfg.borgBackupStartTime}";
                Persistent = true;
              };
            };
          };
        in
        {
          tmpfiles.rules =
            let
              user = config.users.users.${configVars.username}.name;
              group = config.users.users.${configVars.username}.group;
            in
            [ "d ${homeDirectory}/mount/backup/ 0750 ${user} ${group} -" ];
        }
        // serviceEntries;

      environment.systemPackages = [
        pkgs.borgbackup
        borg-backup-list
        borg-backup-mount
        borg-backup-rename
        borg-backup-paths
        borg-backup-test-email
        borg-backup-delete
        borg-backup-restore
      ] ++ lib.optional config.system.impermanence.enable borg-backup-btrfs-subvolume;

      sops.secrets = {
        "private_keys/${config.networking.hostName}_borg" = {
          path = "${config.users.users.root.home}/.ssh/id_borg";
        };
      };
# TODO set this up
#      services.per-network-services.trustedNetworkServices = [ "borg-backup" ];
    }
  );
}