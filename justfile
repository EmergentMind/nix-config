# default recipe to display help information
default:
  @just --list

build:
	git add .
	scripts/build.sh

rebuild:
	git add .
	scripts/system-flake-rebuild.sh
	just check-sops

rebuild-trace:
	git add .
	scripts/system-flake-rebuild-trace.sh
	just check-sops

update:
	nix flake update

rebuild-update:
	just update
	just rebuild

diff:
	git diff ':!flake.lock'

#################### Home Manager #################### 
home:
	# HACK: This is is until the home manager bug is fixed, otherwise any adding extensions deletes all of them
	#rm $HOME/.vscode/extensions/extensions.json || true
	home-manager --impure --flake . switch
	just check-sops

home-update:
	just update
	just home

#################### Secrets Management #################### 
# TODO sops: update or relocate to nix-secrets?
#SOPS_FILE := "./hosts/common/secrets.yaml"

# TODO sops: update or relocate to nix-secrets?
#sops:
	#echo "Editing {{SOPS_FILE}}"
	#nix-shell -p sops --run "SOPS_AGE_KEY_FILE=~/.age-key.txt sops {{SOPS_FILE}}"

# Maybe redundant, but this was used to generate the key on the system that is actually
# managing secrets.yaml. If you don't want to use existing ssh key
sops-init:
	mkdir -p ~/.config/sops/age
	nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"

# Used to generate for the host to decrypt via home-manager
age-keys:
	nix-shell -p age --run "age-keygen -o ~/.age-key.txt"

check-sops:
	scripts/check-sops.sh

# Used when changes have been made to the private nix-secrets repo, which is the flake input
# for `mysecrets` in ./flake.nix   
serets-update:
	nix flake lock --update-input mysecrets