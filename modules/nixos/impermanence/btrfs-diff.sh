#!/usr/bin/env bash
# This script checks for new files on the current root system, or the difference between two root filesystems.
# It assumes that the root filesystem is being wiped every boot, and that there are snapshots of previously wiped
# filesystems (see btrfs-wipe-root.sh).

set -eo pipefail

function red() {
	echo -e "\x1B[31m[!] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[31m[!] $($2) \x1B[0m"
	fi
}
function green() {
	echo -e "\x1B[32m[+] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[32m[+] $($2) \x1B[0m"
	fi
}

function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

# FIXME: Add the ability to diff two root filesystems
function help_and_exit() {
	echo
	echo "Check current root for any files that are not persisted."
	echo "(These files will be lost on a reboot.)"
	echo
	echo Optionally diff the current root with a previous root snapshot.
	echo
	echo "USAGE: $0 [OPTIONS]"
	echo
	echo "OPTIONS:"
	echo "  -b=<btrfs_vol>  Specify the btrfs volume to mount (default: /dev/mapper/encrypted-nixos)"
	echo "  -s=<snapshot>   Specify the snapshot to diff against"
	echo "  --list-old      List the old roots only"
	echo "  -h, --help      Show this help message and exit"
	echo
	exit 1
}

if [ "$UID" -ne "0" ]; then
	red >&2 "ERROR: Must run as superuser to be able to mount main btrfs volume"
	exit 0
fi

SNAPSHOT=""
MOUNTDIR=$(mktemp -d)
BTRFS_VOL=/dev/mapper/encrypted-nixos
ROOT_LABEL=@root
OLD_ROOTS_LABEL=@old_roots
LIST_OLD=0

# Handle command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	--list-old)
		# List the old roots only
		LIST_OLD=1
		;;
	-b*)
		BTRFS_VOL="${1#*=}"
		;;
	-s=*)
		SNAPSHOT="${1#*=}"
		;;
	--debug)
		set -x
		;;
	-h | --help) help_and_exit ;;
	*)
		red "ERROR: Invalid option detected."
		help_and_exit
		;;
	esac
	shift
done

## Mount the btrfs root to a tmpdir so we can check the subvolumes for
## mismatching files.
mount -t btrfs -o subvol=/ "${BTRFS_VOL}" "${MOUNTDIR}"

ROOT_SUBVOL="${MOUNTDIR}/${ROOT_LABEL}"
OLD_ROOTS_SUBVOL="${MOUNTDIR}/${OLD_ROOTS_LABEL}"

if [ "${LIST_OLD}" -eq 1 ]; then
	# List all the old roots
	green "Old roots:"
	cd "${OLD_ROOTS_SUBVOL}"
	find . | tr ' ' '\n'
	cd - >/dev/null
else
	# Diff the current root with a snapshot or list all current non-persisted files
	ROOT_FILES=$(cd "${ROOT_SUBVOL}" && fd -I -H --type file --exclude '/tmp' | sort)

	if [ -n "${SNAPSHOT}" ]; then
		# Diff the specified snapshot
		SNAPSHOT_SUBVOL="${OLD_ROOTS_SUBVOL}/${SNAPSHOT}"
		if [ ! -d "${SNAPSHOT_SUBVOL}" ]; then
			red "ERROR: Snapshot ${SNAPSHOT} does not exist. Use --list-old to list all available snapshots."
			exit 1
		fi
		SNAPSHOT_FILES=$(cd "${SNAPSHOT_SUBVOL}" && fd -I -H --type file --exclude '/tmp' | sort)
		green "${SNAPSHOT} has the following additional files missing from the current root:"
		cd "${SNAPSHOT_SUBVOL}"

		while IFS= read -r file; do
			if [[ ! ${ROOT_FILES} =~ ${file} ]]; then
				eza "${file}"
			fi
		done <<<"${SNAPSHOT_FILES}"
		cd - >/dev/null
	else
		# Show new files on the current root volume only
		green "Ephemeral files on the current root:"
		cd "${ROOT_SUBVOL}"
		while IFS= read -r file; do
			eza "/${file}"
		done <<<"${ROOT_FILES}"
		cd - >/dev/null
	fi
fi
umount "${MOUNTDIR}"
rmdir "${MOUNTDIR}"
