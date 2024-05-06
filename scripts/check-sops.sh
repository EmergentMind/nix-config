#!/usr/bin/env bash
set -euo pipefail

# FIXME: Make this better
sops_result=$(journalctl --no-pager --no-hostname --since "10 minutes ago" |
	tac |
	awk '!flag; /Starting sops-nix activation/{flag = 1};' |
	tac |
	grep sops)

# If we don't have "Finished sops-nix activation." in the logs, then we failed
if [[ ! $sops_result =~ "Finished sops-nix activation" ]]; then
	echo "sops-nix failed to activate"
	echo "$sops_result"
	exit 1
fi
