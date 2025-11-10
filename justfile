SOPS_FILE := "../nix-secrets/.sops.yaml"

# Define path to helpers
export HELPERS_PATH := justfile_directory() + "/scripts/helpers.sh"

[private]
default:
  @just --list

# Update commonly changing flakes and prep for a rebuild
[private]
rebuild-pre: update-nix-secrets update-nix-assets update-nix-index-database
  @git add --intent-to-add .

# Run post-rebuild checks, like if sops is running properly afterwards
[private]
rebuild-post: check-sops

# Run a flake check on the config and installer
[private]
check ARGS="":
	NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}
	cd nixos-installer && NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}

# Rebuild the system
[group("building")]
rebuild: rebuild-pre && rebuild-post
  # NOTE: Add --option eval-cache false if you end up caching a failure you can't get around
  scripts/rebuild.sh

# Rebuild the system and run a flake check
[group("building")]
rebuild-full: rebuild-pre && rebuild-post
  scripts/rebuild.sh
  just check

# Rebuild the system and run a flake check
[group("building")]
rebuild-trace: rebuild-pre && rebuild-post
  scripts/rebuild.sh trace
  just check

# Update the flake
[group("update")]
update:
  nix flake update

# Update and then rebuild
[group("building")]
upgrade: update rebuild

# Generate a new age key
[group("secrets")]
age-key:
  nix-shell -p age --run "age-keygen"

# Check if sops-nix activated successfully
[group("checks")]
check-sops:
  scripts/check-sops.sh

# Update nix-index-database
[group("update")]
update-nix-index-database:
  nix flake update nix-index-database --timeout 5

# Update nix-assets
[group("update")]
update-nix-assets:
  nix flake update nix-assets --timeout 5

# Update nix-secrets flake
[group("update")]
update-nix-secrets:
  @(cd ../nix-secrets && git fetch && git rebase > /dev/null) || true
  nix flake update nix-secrets --timeout 5

# Build an iso image for installing new systems and create a symlink for qemu usage
[group("building")]
iso:
  # If we dont remove this folder, libvirtd VM doesnt run with the new iso...
  rm -rf result
  nix build --impure .#nixosConfigurations.iso.config.system.build.isoImage && ln -sf result/iso/*.iso latest.iso

# Install the latest iso to a flash drive
[group("building")]
iso-install DRIVE: iso
  sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync

# Configure a drive password using disko
[group("misc")]
disko DRIVE PASSWORD:
  echo "{{PASSWORD}}" > /tmp/disko-password
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    disks/btrfs-luks-impermanence-disko.nix \
    --arg disk '"{{DRIVE}}"' \
    --arg password '"{{PASSWORD}}"'
  rm /tmp/disko-password

# Run nixos-rebuild on the remote host
[group("building")]
build-host HOST:
	NIX_SSHOPTS="-p22" nixos-rebuild --target-host {{HOST}} --use-remote-sudo --show-trace --impure --flake .#"{{HOST}}" switch

#
# ========== Nix-Secrets manipulation recipes ==========
#

# Update sops keys in nix-secrets repo
[group("secrets")]
sops-rekey:
  cd ../nix-secrets && for file in $(ls sops/*.yaml); do \
    sops updatekeys -y $file; \
  done

# Update all keys in sops/*.yaml files in nix-secrets to match the creation rules keys
[group("secrets")]
rekey: sops-rekey
  cd ../nix-secrets && \
    (pre-commit run --all-files || true) && \
    git add -u && (git commit -nm "chore: rekey" || true) && git push

# Update an age key anchor or add a new one
[group("secrets")]
sops-update-age-key FIELD KEYNAME KEY:
    #!/usr/bin/env bash
    source {{HELPERS_PATH}}
    sops_update_age_key {{FIELD}} {{KEYNAME}} {{KEY}}

# Update an existing user age key anchor or add a new one
[group("secrets")]
sops-update-user-age-key USER HOST KEY:
  just sops-update-age-key users {{USER}}_{{HOST}} {{KEY}}

# Update an existing host age key anchor or add a new one
[group("secrets")]
sops-update-host-age-key HOST KEY:
  just sops-update-age-key hosts {{HOST}} {{KEY}}

# Automatically create creation rules entries for a <host>.yaml file for host-specific secrets
[group("secrets")]
sops-add-host-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{HELPERS_PATH}}
    sops_add_host_creation_rules "{{USER}}" "{{HOST}}"

# Automatically create creation rules entries for a shared.yaml file for shared secrets
[group("secrets")]
sops-add-shared-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{HELPERS_PATH}}
    sops_add_shared_creation_rules "{{USER}}" "{{HOST}}"

# Automatically add the host and user keys to creation rules for shared.yaml and <host>.yaml
[group("secrets")]
sops-add-creation-rules USER HOST:
    just sops-add-host-creation-rules {{USER}} {{HOST}} && \
    just sops-add-shared-creation-rules {{USER}} {{HOST}}

#
# ========= Admin Recipes ==========
#

# Copy all the config files to the remote host
[group("admin")]
sync USER HOST PATH:
    rsync -av --filter=':- .gitignore' -e "ssh -l {{ USER }} -oport=10022" . {{ USER }}@{{ HOST }}:{{ PATH }}/nix-config
