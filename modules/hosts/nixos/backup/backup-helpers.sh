# shellcheck disable=SC2148

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

function help_and_exit() {
	echo
	echo "${TOOL_DESCRIPTION-borg tool}"
	echo
	echo "USAGE: $(basename "$0") [OPTIONS] ${USAGE:-}"
	echo
	echo "OPTIONS:"
	echo "  --debug         Enable debug output"
	echo "  -h, --help      Show this help message and exit"
	echo "${EXTRA_HELP-}"
	echo
	exit 1
}

parse_args() {
	local min_args=$1
	shift

	if [ $# -lt "$min_args" ]; then
		help_and_exit
	fi

	while [[ $# -gt 0 ]]; do
		case "$1" in
		--debug)
			if [ $# -lt $((min_args + 1)) ]; then
				help_and_exit
			fi
			set -x
			;;
		-h | --help)
			help_and_exit
			;;
		*)
			if [ -z "${POSITIONAL_ARGS-}" ]; then
				POSITIONAL_ARGS=()
			fi
			POSITIONAL_ARGS+=("$1")
			;;
		esac
		shift
	done
}
