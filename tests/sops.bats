AGE_TEST_KEY_1="age1v8v79wlsjnwvxaa6eulqx3zft0m5srj7etgk4v3rg80j42uzecxs26gaxz"
AGE_TEST_KEY_2="age1zmplxr8x2h3tk4fd3zkleyspa7vtnyz5pyrj7zlf5vsl3fquhqvsp8n4k0"
AGE_TEST_KEY_3="age1zrjsjhsuwhqkdn2psjpukrsgjh5qls9023gructewn9skz4ya9gskncgmq"
AGE_TEST_KEY_4="age1e4zy6wcl0a8teaudtmsujkuupf56vkqdul0gljlssdqftrx3uphqqfx8p7"

# This key has a real associated private key in the fixtures
AGE_STATIC_HOST_KEY="age1uq2uymv63r4h5r47vkuhjz3hcz9rv48df8u5jt8zeejgt2wzme3qz3se8y"

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

	sops_update_age_key users alice_testbox "${AGE_TEST_KEY_2}"

	run grep -c "&alice_testbox" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]
	[ "$output" = "1" ]

	run grep "${AGE_TEST_KEY_2}" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]

	teardown
}

@test "add sops host anchor" {
	setup_sops

	sops_update_age_key hosts testbox "${AGE_TEST_KEY_1}"

	run grep -c "&testbox" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]
	[ "$output" = "1" ]

	run grep "${AGE_TEST_KEY_1}" "$NIX_SECRETS_DIR"/.sops.yaml
	[ "$status" -eq 0 ]

	teardown
}

@test "update shared creation rules" {
	setup_sops

	sops_update_age_key users bob_deadbeef "${AGE_TEST_KEY_3}"
	sops_update_age_key hosts deadbeef "${AGE_TEST_KEY_4}"
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

	sops_update_age_key users bob_deadbeef "${AGE_TEST_KEY_1}"
	sops_update_age_key hosts deadbeef "${AGE_TEST_KEY_2}"
	sops_update_age_key users "$(whoami)_$(hostname)" "${AGE_STATIC_HOST_KEY}"
	sops_update_age_key hosts "$(hostname)" "${AGE_STATIC_HOST_KEY}"
	sops_add_host_creation_rules bob deadbeef

	yq '.creation_rules' "$NIX_SECRETS_DIR"/.sops.yaml >"$TEST_TEMP/creation_rules"
	run grep "bob" "$TEST_TEMP/creation_rules"
	[ "$status" -eq 0 ]

	run grep "deadbeef" "$TEST_TEMP/creation_rules"
	[ "$status" -eq 0 ]

	teardown
}

@test "add host.yaml file" {
	setup_sops

	sops_update_age_key users bob_deadbeef "${AGE_TEST_KEY_1}"
	sops_update_age_key hosts deadbeef "${AGE_TEST_KEY_2}"
	sops_update_age_key users "$(whoami)_$(hostname)" "${AGE_STATIC_HOST_KEY}"
	sops_update_age_key hosts "$(hostname)" "${AGE_STATIC_HOST_KEY}"
	sops_add_host_creation_rules bob deadbeef

	# Create a new <host>.yaml file and verify it holds the correct entry
	export SOPS_AGE_KEY_FILE="$BATS_TEST_DIRNAME/fixtures/nix-secrets/age_key.txt"
	run sops_setup_user_age_key "deadbeef" "bob"
	[ "$status" -eq 0 ]

	teardown
}
