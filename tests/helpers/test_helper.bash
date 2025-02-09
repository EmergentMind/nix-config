setup() {
	TEST_TEMP="$(mktemp -d)"
	FIXTURES_DIR="$(dirname "$BATS_TEST_DIRNAME")/tests/fixtures"
	export TEST_TEMP
	export FIXTURES_DIR
}
teardown() {
	rm -rf "$TEST_TEMP"
}
