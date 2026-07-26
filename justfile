# Define path to helpers

export HELPERS_PATH := justfile_directory() + "../introdus/pkgs/introdus-helpers/helpers.sh"

[private]
default:
    @just --list

# Update commonly changing flakes and prep for a build
[private]
rebuild-pre HOST=`hostname`:
    just update-nix-secrets {{ HOST }} && \
    just update {{ HOST }} nix-assets && \
    just update {{ HOST }} emergentvim && \
    just update {{ HOST }} nix-index-database && \
    just update {{ HOST }} introdus && \
    git add --intent-to-add . && \
    just update-neovim-flake

# Run post-build checks, like if sops is running properly afterwards
[private]
rebuild-post: check-sops

# Run nix flake update on neovim flake to ensure latest introdus is input
[private]
update-neovim-flake:
  cd /home/ta/dev/nix/neovim && \
  nix flake update introdus

# Run a flake check on the config and installer
[group("checks")]
check HOST=`hostname` ARGS="":
    NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check \
        --impure \
        --keep-going \
        --show-trace \
        {{ ARGS }}
    cd nixos-installer && \
        NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check \
        --impure \
        --keep-going \
        --show-trace \
        {{ ARGS }}

# Rebuild specified host
[group("building")]
rebuild HOST=`hostname`: && rebuild-post
    @just rebuild-host {{ HOST }}

# Rebuild the system and then run a flake check
[group("building")]
rebuild-full HOST=`hostname`: && rebuild-post
    @just rebuild-host {{ HOST }}
    just check {{ HOST }}

# Update all flake inputs for the specified host or the current host if none specified
[group("update")]
update HOST=`hostname` *INPUT:
    nix flake update {{ INPUT }} --timeout 5

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
    check-sops

# Update nix-secrets flake
[group("update")]
update-nix-secrets HOST=`hostname`:
    @(cd ../nix-secrets 2>/dev/null && git fetch && git rebase > /dev/null || echo "Push your nix-secrets changes") || true
    @just update {{ HOST }} nix-secrets

# Build an iso image for installing new systems and create a symlink for qemu usage
[group("building")]
iso HOST:
    # If we dont remove this folder, libvirtd VM doesnt run with the new iso
    rm -rf result
    nix build --impure .#nixosConfigurations.iso.config.system.build.isoImage --reference-lock-file locks/{{ HOST }}.lock && ln -sf result/iso/*.iso latest_{{ HOST }}.iso

# Install the latest iso to a flash drive
[group("building")]
iso-install DRIVE HOST=`hostname`:
    just iso {{ HOST }}
    sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{ DRIVE }} bs=4M status=progress oflag=sync

# Configure a drive password using disko
[group("misc")]
disko DRIVE PASSWORD:
    echo "{{ PASSWORD }}" > /tmp/disko-password
    sudo nix --experimental-features "nix-command flakes pipe-operators" run github:nix-community/disko -- \
      --mode disko \
      hosts/common/disks/btrfs-luks-impermanence-disko.nix \
      --arg disk '"{{ DRIVE }}"' \
      --arg password '"{{ PASSWORD }}"'
    rm /tmp/disko-password

# Run nixos-rebuild on the remote host
[group("building")]
rebuild-host HOST=`hostname`:
    @just rebuild-pre {{ HOST }}
    @rebuild-host {{ HOST }}

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
    source {{ HELPERS_PATH }}
    sops_update_age_key {{ FIELD }} {{ KEYNAME }} {{ KEY }}

# Update an existing user age key anchor or add a new one
[group("secrets")]
sops-update-user-age-key USER HOST KEY:
    just sops-update-age-key users {{ USER }}_{{ HOST }} {{ KEY }}

# Update an existing host age key anchor or add a new one
[group("secrets")]
sops-update-host-age-key HOST KEY:
    just sops-update-age-key hosts {{ HOST }} {{ KEY }}

# Automatically create creation rules entries for a <host>.yaml file for host-specific secrets
[group("secrets")]
sops-add-host-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{ HELPERS_PATH }}
    sops_add_host_creation_rules "{{ USER }}" "{{ HOST }}"

# Automatically create creation rules entries for a shared.yaml file for shared secrets
[group("secrets")]
sops-add-shared-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{ HELPERS_PATH }}
    sops_add_shared_creation_rules "{{ USER }}" "{{ HOST }}"

# Automatically add the host and user keys to creation rules for shared.yaml and <host>.yaml
[group("secrets")]
sops-add-creation-rules USER HOST:
    just sops-add-host-creation-rules {{ USER }} {{ HOST }} && \
    just sops-add-shared-creation-rules {{ USER }} {{ HOST }}

#
# ========= Admin Recipes ==========
#

# Pin the current nixos generation of a host to the systemd-boot loader menu
[group("admin")]
pin HOST=`hostname`:
    #!/usr/bin/env bash
    shopt -u expand_aliases

    cmd_prefix=''
    cp_cmd='cp '
    if [ "{{ HOST }}" != "$(hostname)" ]; then
        cmd_prefix="ssh {{ HOST }}"
        cp_cmd="scp {{ HOST }}:"
    fi

    if [ ! -e "hosts/nixos/{{ HOST }}/" ]; then
        echo "ERROR: there is no {{ HOST }} host in this config"
        exit 1
    fi

    # Create a modified copy of the current systemd-boot entry and denote it as pinned
    CURRENT=$($cmd_prefix sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | rg current | awk '{print $1}')
    if [[ -z $CURRENT ]]; then
        echo "ERROR: Failed to find nixos generation."
        exit 1
    fi
    PINNED=hosts/nixos/{{ HOST }}/pinned-boot-entry.conf
    ${cp_cmd}/boot/loader/entries/nixos-generation-$CURRENT.conf $PINNED
    chmod -x $PINNED
    sed -i 's/sort-key nixos/sort-key pinned/' $PINNED
    VERSION=$(grep version $PINNED | cut -f2- -d' ')
    sed -i "s/title.*/title PINNED: $VERSION/" $PINNED

    # Set the new root to prevent garbage collection
    PINNED_ROOT=/nix/var/nix/gcroots/pinned-{{ HOST }}
    $exec_prefix sudo nix-store --add-root $PINNED_ROOT -r /nix/var/nix/profiles/system >/dev/null
    git add $PINNED
    git commit -m "chore: pin {{ HOST }} boot entry for generation $CURRENT"
    echo "Pinned generation $CURRENT to $PINNED_ROOT"
    # Rebuild in order for the newly pinned generation to populate in systemd-boot,
    echo "Rebuilding {{ HOST }} to populate boot entry..." && sleep 2
    just rebuild {{ HOST }}

# Copy all the config files to the remote host
[group("admin")]
sync USER HOST PATH:
    rsync -av --filter=':- .gitignore' -e "ssh -l {{ USER }} -oport=22" . {{ USER }}@{{ HOST }}:{{ PATH }}/nix-config

# Generate remote facter.json and add it to the repo. Mostly for migrating hosts. Use nixos-bootstrap.sh otherwise
[group("admin")]
facter HOST:
    #!/usr/bin/env bash
    if ssh {{ HOST }} "sudo /bin/sh -c 'nix run --option experimental-features \"nix-command flakes pipe-operators\" nixpkgs#nixos-facter -- -o facter.json' && sudo chmod 644 facter.json" && \
    scp {{ HOST }}:/home/$USER/facter.json hosts/nixos/{{ HOST }}/ && \
    chown $USER:$(id -g) hosts/nixos/{{ HOST }}/facter.json; then
        if ! grep facter .gitattributes | grep -q crypt; then
            echo "WARNING: You are potenttially exposing your facter.json file publicly. Add a git-crypt entry to .gitattributes"
            exit 0
        else
            echo "Added and generated hosts/nixos/{{ HOST }}/facter.json"
            git add hosts/nixos/{{ HOST }}/facter.json
        fi
    fi

# Refresh dev environment with updated inputs
[group("dev")]
dev:
    @just rebuild-pre
    direnv reload

[group("dev")]
fmt:
    nix fmt --reference-lock-file locks/$(hostname).lock

# Generate json diff of current noctalia settings
[group("noctalia")]
noctalia-diff:
    nix shell nixpkgs#json-diff -c bash -c "json-diff <(jq -S . ~/.config/noctalia/settings.json) <(noctalia-shell ipc call state all | jq -S .settings)"

# Dump noctalia settings
[group("noctalia")]
noctalia-json:
    noctalia-shell ipc call state all | jq -S .settings

# Dump noctalia settings as nix
[group("noctalia")]
noctalia-nix:
    @just noctalia-json | json2nix
