#!/usr/bin/env bash
set -euo pipefail

get_file_type() {
	local file_path=$1

	local file_mode
	file_mode=$(stat -c "%F" "$file_path")

	case "$file_mode" in
	"regular file")
		echo "fi"
		;;
	"directory")
		echo "di"
		;;
	"symbolic link")
		echo "ln"
		;;
	*)
		# This is reset to the default color
		echo "rs"
		;;
	esac
}

# Function to get the color code for a file type from LS_COLORS
get_color_code() {
	local file_type
	file_type=$1
	local color_code
	color_code=$(echo "$LS_COLORS" | sed 's/:/\n/g' | grep "^${1}=" | sed 's/.*=//')
	echo "$color_code"
}

if [ $# -ne 1 ]; then
	echo "Usage: $0 <symlink>"
fi
current_link=$1

while [ -L "$current_link" ]; do
	# Get the color code for symbolic links from LS_COLORS
	file_type=$(get_file_type "$current_link")
	link_color_code=$(get_color_code "${file_type}")

	# Print the symbolic link with the appropriate color
	new_link=$(readlink "$current_link")
	if [[ $new_link != /* ]]; then
		new_link="$(dirname "$current_link")/$new_link"
	fi
	new_link_file_type=$(get_file_type "$new_link")
	new_link_color_code=$(get_color_code "${new_link_file_type}")
	echo -e "\e[${link_color_code}m$current_link\e[0m -> \e[${new_link_color_code}m$new_link\e[0m"
	current_link="$new_link"
done

# Print the final resolved path
file_type=$(get_file_type "$current_link")
final_path_color_code=$(get_color_code "${file_type}")
echo -e "Final path: \e[${final_path_color_code}m$current_link\e[0m"
