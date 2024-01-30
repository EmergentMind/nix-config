#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
	echo "Usage: $0 <github-repo>"
fi

# There will always be a /blob/<commit or branch>/ in the URL, which we just need to replace with /trunk/
repo=$(echo "$1" | sed -E 's|/blob/[^/]+/|/trunk/|')
svn export "${repo}"
