#!/usr/bin/env bash
## Reset current root to clear any files that are not persisted.
## This is built to run during stage-0 (see impermanence.nix rollback service).
##
## This script makes some critical assumptions about how the filesystem has
## been created.
##
## Note that unlike similar scripts, we don't use a blank snap shot to reset the root,
## instead we delete the root and create a new one.

mkdir /btrfs_tmp
echo "Testing mount"

mount -t btrfs -o subvol=/ /dev/mapper/encrypted-nixos /btrfs_tmp

if [[ -e /btrfs_tmp/@root ]]; then
	mkdir -p /btrfs_tmp/@old_roots
	timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%-d_%H:%M:%S")
	mv /btrfs_tmp/@root "/btrfs_tmp/@old_roots/$timestamp"
fi

delete_subvolume_recursively() {
	IFS=$'\n'
	for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
		delete_subvolume_recursively "/btrfs_tmp/$i"
	done
	btrfs subvolume delete "$1"
}

find /btrfs_tmp/@old_roots/ -maxdepth 1 -mtime +30 | while read -r old; do
	delete_subvolume_recursively "$old"
done

btrfs subvolume create /btrfs_tmp/@root
umount /btrfs_tmp