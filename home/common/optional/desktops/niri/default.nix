{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  spawn-noctalia-settings = pkgs.writeShellApplication {
    name = "spawn-noctalia-settings";
    runtimeInputs = lib.attrValues {
      inherit (pkgs)
        jq
        ;
    };
    text =
      # bash
      ''
          APP_ID="dev.noctalia.noctalia-qs"
          WIN_ID=$(niri msg --json windows | jq -r ".[] | select(.app_id == \"$APP_ID\") | .id" | head -n 1)
        if [ -n "$WIN_ID" ]; then
             niri msg action focus-window --id "$WIN_ID"
        else
             noctalia-shell ipc call settings open
        fi
      '';
  };
  spawn-nvim-scratchpad = pkgs.writeShellApplication {
    name = "spawn-nvim-scratchpad";
    runtimeInputs = lib.attrValues {
      inherit (pkgs.unstable) nirius;
    };
    text =
      # bash
      ''
        APP_ID="neovide-scratchpad"
        if ! niri msg --json windows | jq -e --arg app "$APP_ID" '.[] | select(.app_id == $app)' > /dev/null; then
            NEOVIDE_APP_ID="$APP_ID" nvim-neovide -- -c 'lua require([[resession]]).load([[nix]])' &

            # Poll for window creation (up to 2 seconds max)
            for _ in $(seq 1 20); do
                if niri msg --json windows | jq -e --arg app "$APP_ID" '.[] | select(.app_id == $app)' > /dev/null; then
                    break
                fi
                sleep 0.1
            done

            nirius scratchpad-toggle -a "$APP_ID"
        fi
      '';
  };
  # nirius scratchpad doesn't play nicely with fullscreen-window, so this script has to be run manually
  # FIXME: Would be nice to record the dimensions of the window instead of hardcoding 70%
  niri-fullscreen-window = pkgs.writeShellApplication {
    name = "niri-fullscreen-window";
    runtimeInputs = [
      pkgs.unstable.niri
      pkgs.jq
    ];
    text = # bash
      ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Extract App ID
        WIN_JSON=$(niri msg --json focused-window)
        APP_ID=$(echo "$WIN_JSON" | jq -r '.app_id // ""')

        # If not a nirius scratchpad window, fall back to standard fullscreen
        if [[ "$APP_ID" != *"-scratchpad" ]]; then
            niri msg action fullscreen-window
            exit 0
        fi

        # Fetch focused window and output metadata
        OUT_JSON=$(niri msg --json focused-output)

        # Ensure window is focused and floating
        IS_FLOATING=$(echo "$WIN_JSON" | jq -r '.is_floating // false')
        if [[ "$IS_FLOATING" != "true" ]]; then
            exit 0
        fi

        # Extract window logical dimensions
        WIN_W=$(echo "$WIN_JSON" | jq -r '.size[0] // .layout.window_size[0] // 0')
        WIN_H=$(echo "$WIN_JSON" | jq -r '.size[1] // .layout.window_size[1] // 0')

        # Extract monitor logical dimensions
        # (IMPORTANT: need to use logical due to possible fractional scaling)
        OUT_W=$(echo "$OUT_JSON" | jq -r '.logical.width // 0')
        OUT_H=$(echo "$OUT_JSON" | jq -r '.logical.height // 0')

        # Fallback check
        if [[ "$OUT_W" -eq 0 || "$OUT_H" -eq 0 ]]; then
            exit 1
        fi

        # Calculate percentage of monitor space occupied
        PCT_W=$(( WIN_W * 100 / OUT_W ))
        PCT_H=$(( WIN_H * 100 / OUT_H ))

        # If window occupies >= 90% of both width and height, shrink it
        # 90 works better due to rounding
        if [[ "$PCT_W" -ge 90 && "$PCT_H" -ge 90 ]]; then
            RATIO="70%"
        else
            RATIO="95%"
        fi

        niri msg action set-window-width "$RATIO"
        niri msg action set-window-height "$RATIO"
        sleep 0.02
        niri msg action center-window
      '';
  };
in
{
  imports = [
    ./scripts.nix
  ];
  home = {
    packages =
      lib.attrValues {
        inherit (pkgs.unstable)
          niri
          xwayland-satellite # xwayland support
          ;
      }
      ++ [
        spawn-noctalia-settings
        spawn-nvim-scratchpad
        niri-fullscreen-window
      ];
    file =
      let
        hostPath = "hosts/nixos/${osConfig.hostSpec.hostName}/niri";
        finalConfig =
          lib.flatten [
            # order matters
            ./inputs.kdl
            (map lib.custom.relativeToRoot [
              "${hostPath}/outputs.kdl"
              "${hostPath}/workspaces.kdl"
              "${hostPath}/startup.kdl"
            ])
            ./binds.kdl
            ./rules.kdl
            ./config.kdl
          ]
          |> lib.concatMapStringsSep "\n" lib.readFile;
        # Validates the Niri configuration
        configFile = pkgs.writeText "niri-config.kdl" finalConfig;
        checkNiriConfig = pkgs.runCommandLocal "niri-config" { buildInputs = [ pkgs.unstable.niri ]; } ''
          mkdir -p build/animations//
          cp ${configFile} build/config.kdl
          cp -r ${./animations}/* build/animations/

          # Validate relative to the staged build tree
          niri validate --config build/config.kdl
          cp ${configFile} $out
        '';
      in
      {
        ".config/niri/config.kdl".source = checkNiriConfig;
        ".config/niri/animations/" = {
          source = ./animations;
          recursive = true;
        };
      };
  };
}
