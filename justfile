SOPS_FILE := "../nix-secrets/secrets.yaml"

# default recipe to display help information
default:
  @just --list

rebuild-pre:
	nix flake lock --update-input nixvim-flake
	just update-nix-secrets
	git add *.nix

rebuild-post:
	just check-sops

# Add --option eval-cache false if you end up caching a failure you can't get around
rebuild:
	just rebuild-pre
	scripts/system-flake-rebuild.sh
	just rebuild-post

rebuild-full:
	just rebuild-pre
	scripts/system-flake-rebuild.sh
	just rebuild-post

rebuild-trace:
	just rebuild-pre
	scripts/system-flake-rebuild-trace.sh
	just rebuild-post

update:
	nix flake update

rebuild-update:
	just update
	just rebuild

diff:
	git diff ':!flake.lock'

# Run ci using pre-commit
ci:
  pre-commit run

# Run ci for all files using pre-commit
ci-all:
  pre-commit run --all-files

#################### Home Manager ####################

# Run `home-manager --impure --flake . switch` and `just check-sops`
home:
  # HACK: This is is until the home manager bug is fixed, otherwise any adding extensions deletes all of them
  # rm $HOME/.vscode/extensions/extensions.json || true
  home-manager --impure --flake . switch
  just check-sops

# Run `just update` and `just home`
home-update:
  just update
  just home

#################### Secrets Management ####################
sops:
  @echo "Editing {{SOPS_FILE}}"
  nix-shell -p sops --run "SOPS_AGE_KEY_FILE=~/.age-key.txt sops {{SOPS_FILE}}"

# Maybe redundant, but this was used to generate the key on the system that is actually
# managing secrets.yaml. If you don't want to use existing ssh key
sops-init:
  mkdir -p ~/.config/sops/age
  nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"

# Used to generate for the host to decrypt via home-manager
age-keys:
  nix-shell -p age --run "age-keygen -o ~/.age-key.txt"

# Check for successful sops activation.
check-sops:
  scripts/check-sops.sh

update-nix-secrets:
	(cd ~/src/nix-secrets && git fetch && git rebase) || true
	nix flake lock --update-input nix-secrets

#################### Installation ####################

iso:
	# If we dont remove this folder, libvirtd VM doesnt run with the new iso...
	rm -rf result
	nix build .#nixosConfigurations.iso.config.system.build.isoImage

iso-install DRIVE:
	just iso
	sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync

disko DRIVE PASSWORD:
	echo "{{PASSWORD}}" > /tmp/disko-password
	sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
		--mode disko \
		disks/btrfs-luks-impermanence-disko.nix \
		--arg disk '"{{DRIVE}}"' \
		--arg password '"{{PASSWORD}}"'
	rm /tmp/disko-password

sync USER HOST:
	rsync -av --filter=':- .gitignore' -e "ssh -l {{USER}}" . {{USER}}@{{HOST}}:nix-config/
