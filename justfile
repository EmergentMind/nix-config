SOPS_FILE := "../nix-secrets/secrets.yaml"

# default recipe to display help information
default:
  @just --list

build:
	git add *.nix
	scripts/build.sh

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

#requires sops to be running, must have reboot after inital rebuild
rebuild-full:
	just rebuild-pre
	scripts/system-flake-rebuild.sh
	just rebuild-post

#requires sops to be running, must have reboot after inital rebuild
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

#################### Home Manager ####################
home:
	just rebuild-pre
	home-manager --impure --flake . switch
	just rebuild-post

home-update:
	just update
	just home

#################### Secrets Management ####################
sops:
	echo "Editing {{SOPS_FILE}}"
	nix-shell -p sops --run "SOPS_AGE_KEY_FILE=~/.age-key.txt sops {{SOPS_FILE}}"

age-key:
	nix-shell -p age --run "age-keygen"

rekey:
	cd ../nix-secrets && (\
		sops updatekeys -y secrets.yaml && \
		(pre-commit run --all-files || true) && \
		git add -u && (git commit -m "chore: rekey" || true) && git push \
	)
check-sops:
	scripts/check-sops.sh

update-nix-secrets:
	(cd ../nix-secrets && git fetch && git rebase) || true
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

sync-secrets USER HOST:
	rsync -av --filter=':- .gitignore' -e "ssh -l {{USER}}" . {{USER}}@{{HOST}}:nix-secrets/