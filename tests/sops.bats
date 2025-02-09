setup_sops() {
	load 'helpers/test_helper'
	setup
	mkdir -p "$TEST_TEMP"
	cp -R "$FIXTURES_DIR"/nix-secrets/*.yaml "$TEST_TEMP"
	mv "$TEST_TEMP/sops.yaml" "$TEST_TEMP/.sops.yaml"
	NIX_SECRETS_DIR="$TEST_TEMP"
	export NIX_SECRETS_DIR
	# shellcheck disable=SC1091
	source "$BATS_TEST_DIRNAME/../scripts/helpers.sh"
}
@test "add sops user anchor" {
	setup_sops
	sops_update_age_key users alice_testbox USER_KEY_2
	run grep -c "&alice_testbox" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]
	[ "$output" = "1" ]
	run grep "USER_KEY_2" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]
	teardown
}
@test "add sops host anchor" {
	setup_sops
	sops_update_age_key hosts testbox HOST_KEY_2
	run grep -c "&testbox" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]
	[ "$output" = "1" ]
	run grep "HOST_KEY_2" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]
	teardown
}
@test "update shared creation rules" {
	setup_sops
	sops_update_age_key users bob_deadbeef USER_KEY_3
	sops_update_age_key hosts deadbeef HOST_KEY_3
	sops_add_shared_creation_rules bob deadbeef
	yq '.creation_rules' "$NIX_SECRETS_DIR"/.sops.yaml >"$TEST_TEMP/creation_rules"
	run grep "bob" "$TEST_TEMP/creation_rules"
	[ "$status" -eq 0 ]
	run grep "deadbeef" "$TEST_TEMP/creation_rules"
	[ "$status" -eq 0 ]
	teardown
}
@test "add host creation rules to sops" {
	setup_sops
	sops_update_age_key users bob_deadbeef USER_KEY_3
	sops_update_age_key hosts deadbeef HOST_KEY_3
	sops_update_age_key users "$(whoami)_$(hostname)" USER_KEY_4
	sops_update_age_key hosts "$(hostname)" HOST_KEY_4
	sops_add_host_creation_rules bob deadbeef
	yq '.creation_rules' "$NIX_SECRETS_DIR"/.sops.yaml >"$TEST_TEMP/creation_rules"
	run grep "bob" "$TEST_TEMP/creation_rules"
	[ "$status" -eq 0 ]
	run grep "deadbeef" "$TEST_TEMP/creation_rules"
	[ "$status" -eq 0 ]
	teardown
}
