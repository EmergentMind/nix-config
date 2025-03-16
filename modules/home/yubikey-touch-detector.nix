# See https://github.com/berbiche/dotfiles/blob/4048a1746ccfbf7b96fe734596981d2a1d857930/modules/home/yubikey-touch-detector.nix#L9
# FIXME: Send a PR to HM to add this service
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.yubikey-touch-detector;
in
{
  options.services.yubikey-touch-detector = {
    enable = mkEnableOption "a tool to detect when your YubiKey is waiting for a touch";

    package = mkOption {
      type = types.package;
      default = pkgs.yubikey-touch-detector;
      defaultText = "pkgs.yubikey-touch-detector";
      description = ''
        Package to use. Binary is expected to be called "yubikey-touch-detector".
      '';
    };

    socket.enable = mkEnableOption "starting the process only when the socket is used";

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ "--libnotify" ];
      defaultText = literalExpression ''[ "--libnotify" ]'';
      description = ''
        Extra arguments to pass to the tool. The arguments are not escaped.
      '';
    };
    notificationSound = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Play sounds when the YubiKey is waiting for a touch.
      '';
    };
    notificationSoundFile = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/window-attention.oga";
      description = ''
        Path to the sound file to play when the YubiKey is waiting for a touch.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Service description licensed under ISC
    # See https://github.com/maximbaz/yubikey-touch-detector/blob/c9fdff7163361d6323e2de0449026710cacbc08a/LICENSE
    # Author: Maxim Baz
    systemd.user.sockets.yubikey-touch-detector = mkIf cfg.socket.enable {
      Unit.Description = "Unix socket activation for YubiKey touch detector service";
      Socket = {
        ListenFIFO = "%t/yubikey-touch-detector.sock";
        RemoveOnStop = true;
        SocketMode = "0660";
      };
      Install.WantedBy = [ "sockets.target" ];
    };

    # Same license thing for the description here
    systemd.user.services.yubikey-touch-detector = {
      Unit = {
        Description = "Detects when your YubiKey is waiting for a touch";
        Requires = optionals cfg.socket.enable [ "yubikey-touch-detector.socket" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/yubikey-touch-detector ${concatStringsSep " " cfg.extraArgs}";
        Environment = [ "PATH=${lib.makeBinPath [ pkgs.gnupg ]}" ];
        Restart = "on-failure";
        RestartSec = "1sec";
      };
      Install.Also = optionals cfg.socket.enable [ "yubikey-touch-detector.socket" ];
      Install.WantedBy = [ "default.target" ];
    };
    # Play sound when the YubiKey is waiting for a touch
    systemd.user.services.yubikey-touch-detector-sound =
      let
        file = cfg.notificationSoundFile;
        yubikey-play-sound = pkgs.writeShellScriptBin "yubikey-play-sound" ''
          socket="''${XDG_RUNTIME_DIR:-/run/user/$UID}/yubikey-touch-detector.socket"

          while true; do

              if [ ! -e "$socket" ]; then
                  printf '{"text": "Waiting for YubiKey socket"}\n'
                  while [ ! -e "$socket" ]; do sleep 1; done
              fi
              printf '{"text": ""}\n'

              ${lib.getBin pkgs.netcat}/bin/nc -U "$socket" | while read -n5 cmd; do

                if [ "''${cmd:4:1}" = "1" ]; then
                  printf "Playing ${file}\n"
                  ${pkgs.mpv}/bin/mpv --volume=100 ${file} > /dev/null
                else
                  printf "Ignored yubikey command: $cmd\n"
                fi
              done

              ${lib.getBin pkgs.coreutils}/bin/sleep 1
          done
        '';
      in
      lib.mkIf cfg.notificationSound {
        Unit = {
          Description = "Play sound when the YubiKey is waiting for a touch";
          Requires = [ "yubikey-touch-detector.service" ];
        };
        Service = {
          ExecStart = "${lib.getBin yubikey-play-sound}/bin/yubikey-play-sound";
          Restart = "on-failure";
          RestartSec = "1sec";
        };
        Install.WantedBy = [ "yubikey-touch-detector.service" ];
      };
  };
}
