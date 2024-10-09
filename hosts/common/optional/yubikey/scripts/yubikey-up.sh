#!/usr/bin/env bash
set -euo pipefail

serial=$(ykman list | awk '{print $NF}')
# If it got unplugged before we ran, just don't bother
if [ -z "$serial" ]; then
	# FIXME: Warn probably
	exit 0
fi

declare -A serials=([mara]="14574244" [maya]="12549033")

key_name=""
for key in "${!serials[@]}"; do
	if [[ $serial == "${serials[$key]}" ]]; then
		key_name="$key"
	fi
done

if [ -z "$key_name" ]; then
	echo WARNING: Unidentified yubikey with serial "${serial}" . Won\'t link an SSH key.
	exit 0
fi

echo "Creating links to ~/.ssh/id_${key_name}"
ln -sf "~/.ssh/id_${key_name}" ~/.ssh/id_yubikey
ln -sf "~/.ssh/id_${key_name}.pub" ~/.ssh/id_yubikey.pub
