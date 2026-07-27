# Automatically add some conveniences when the host has microvm
# microvms setup

{
  lib,
  pkgs,
  config,
  osConfig,
  namespace,
  ...
}:
let
  cfg = osConfig.${namespace}.microvms;
  home = config.home.homeDirectory;
  sharedDir = "${cfg.sharedDir}/shared";
in
lib.mkIf (lib.length (lib.attrNames osConfig.microvm.vms) != 0) {

  # Automatic ssh entries
  programs.ssh.settings =
    osConfig.microvm.vms
    |> lib.attrNames
    |> map (
      name:
      let
        vmSpecs = osConfig.microvm.vms.${name}.specialArgs.vmSpecs;
      in
      {
        "${name}" = {
          match = "host ${name}";
          hostname = vmSpecs.ip;
          port = vmSpecs.sshPort;
          user = vmSpecs.user;
          identityFile = "${home}/.ssh/id_ed25519";
        };
      }
    )
    |> lib.mergeAttrsList;

  home.packages = lib.attrValues {
    inherit (pkgs)
      bindfs
      ;
  };

  programs.zsh = {
    shellAliases = {
      # Microvm management
      mv-start = "function _mv-start() { systemctl start microvm@$1 }; _mv-start";
      mv-stop = "function _mv-stop() { systemctl stop microvm@$1 }; _mv-stop";
      mv-restart = "function _mv-restart() { systemctl restart microvm@$1 }; _mv-restart";
      mv-status = "_mv-status";
      mv-status-all = "_mv-status-all";
      mv-log = "_mv-log";
      mv-log-all = "_mv-log-all";
      mv-deps = "function _mv-deps() { systemctl list-dependencies \"microvm@$1.service\" }; _mv-deps";
      mv-list = "get_microvms";
      mv-list-running = "systemctl list-units \"microvm@*.service\" --state=running";
      mv-list-stopped = "systemctl list-units \"microvm@*.service\" --state=inactive";
      mvl = "mv-list";
      mvlr = "mv-list-running";
      mvls = "mv-list-stopped";

      # I bind mount some folders into microvm view, so this allows easy lookup
      mv-binds = "_mv-binds";
      mvlb = "mv-binds";
      mv-unbind = "mv-unbind";
      mv-unbind-all = "";
      mv-bind = "_mv-bind";
      mvb = "mv-bind";
      # FIXME: finish
      mv-umount-all = "";

      # VM-specific helpers that need to be moved
      agent = "ssh nano zla agents"; # Attach to agent session
    };
    # Helper functions for aliases that are annoying to inline
    initContent =
      lib.mkAfter
        # bash
        ''
          zmodload zsh/mapfile

          function get_microvms() {
            if [ $# -gt 0 ]; then
              echo "$1"
            else
              ls -1 ${osConfig.microvm.stateDir}
            fi
          }

          # Show systemctl status for the main service of one or more microvms
          function _mv-status() {
            for vm in $(get_microvms "$@"); do
              systemctl status "microvm@$vm.service"
            done
          };

          # Return status of all services related to one or more vm's
          function _mv-status-all() {
            for vm in $(get_microvms "$@"); do
              systemctl status "*@$vm.service"
            done
          };

          function _mv-log() {
            if [ $# -lt 1 ]; then
              echo "Usage: mv-log <vm-name>"
              exit 1
            fi
            journalctl -u microvm@$1.service
          }

          function _mv-log-all() {
            local args=()
            for vm in $(get_microvms "$@"); do
              args+=("-u" "$vm")
            done
            journalctl ''${args[@]} -e;
          };

          function _mv-binds() {
            MICROVM_SHARED_PATH=''${MICROVM_SHARED_PATH:-${sharedDir}}
            if [ "$#" -ne 1 ]; then
              vm_list=( ''${(f@)"$(get_microvms)"} )
            else
              vm_list=( ''${(f)1} )
            fi

            local json_output
            json_output=$(findmnt --submounts --target "$MICROVM_SHARED_PATH" -J 2>/dev/null)
            if [ -z "$json_output" ]; then
              echo "No active mounts found @ '$MICROVM_SHARED_PATH'."
              return 0
            fi

            for target_vm in ''${vm_list[@]}; do
              if [ $#vm_list -gt 1 ]; then
                echo "$target_vm mounts:"
                echo ----
              fi
              echo "$json_output" |
                jq -r --arg prefix "$MICROVM_SHARED_PATH/$target_vm" '
                  .. | objects | select(.target? | strings | startswith($prefix)) |
                  "\(.target | split("/") | last) -> \(.target) (\(.source))"
                '
              if [ $#vm_list -gt 1 ]; then
                echo ----
              fi
            done
          }


          function _mv-bind() {
              MICROVM_SHARED_PATH=''${MICROVM_SHARED_PATH:-${sharedDir}}
              if [ "$#" -ne 2 ]; then
                echo "Usage: mv-bind <microvm-name> <source_path>" >&2
                echo "Example: mv-bind <microvm-name> ~/dev/new-project" >&2
                echo
                echo "This will create a $MICROVM_SHARED_PATH/<microvm-name>/new-project"
                echo " folder and bind mount ~/dev/new-project/ to the folder"
                return 1
              fi

              local target_vm="$1"
              local source_raw="$2"

              if [ ! -d "$source_raw" ]; then
                echo "Error: Source directory '$source_raw' does not exist." >&2
                return 1
              fi
              local source_abs
              source_abs=$(realpath "$source_raw")

              local leaf_node
              leaf_node=$(basename "$source_abs")

              local dest_dir="$MICROVM_SHARED_PATH/$target_vm/$leaf_node"

              if [ ! -d "$dest_dir" ]; then
                echo "Creating mount point: $dest_dir"
                mkdir -p "$dest_dir"
              fi

              # Check if something is already mounted there to prevent stacking
              # FIXME: Double check this as I don't think it works
              if findmnt "$dest_dir" >/dev/null 2>&1; then
                echo "Warning: Something is already mounted at '$dest_dir'." >&2
                return 1
              fi

              # Execute the bindfs mount
              echo "Mounting $source_abs -> $dest_dir"
              if ${lib.getExe pkgs.bindfs} "$source_abs" "$dest_dir"; then
                echo "Success!"
              else
                echo "Error: bindfs failed to mount." >&2
                return 1
              fi
          };

          function mv-unbind() {
            if [ "$#" -ne 2 ]; then
              echo "Usage: mv-unbind <microvm-name> <leaf_node>" >&2
              echo "Example: mv-unbind nano project" >&2
              echo
              echo "This would unmount ${sharedDir}/nano/project"
            fi
            umount -l ''${MICROVM_SHARED_PATH:-${sharedDir}/$1/$2}
          };
        '';
  };
}
