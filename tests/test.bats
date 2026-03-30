#!/usr/bin/env bats

setup() {
  export DDEV_SITENAME="test-site"
  export DDEV_HOSTNAME="test-site.ddev.site"
  export DDEV_APPROOT="/tmp/test-app"
}

@test "install.yaml exists and has required fields" {
  [ -f "$BATS_TEST_DIRNAME/../install.yaml" ]
  grep -q "name: decodie" "$BATS_TEST_DIRNAME/../install.yaml"
  grep -q "config.decodie.yaml" "$BATS_TEST_DIRNAME/../install.yaml"
}

@test "config.decodie.yaml defines web_extra_daemons" {
  [ -f "$BATS_TEST_DIRNAME/../config.decodie.yaml" ]
  grep -q "web_extra_daemons" "$BATS_TEST_DIRNAME/../config.decodie.yaml"
  grep -q "decodie" "$BATS_TEST_DIRNAME/../config.decodie.yaml"
}

@test "traefik script generates correct config" {
  tmpdir=$(mktemp -d)
  HOME="$tmpdir" DDEV_SITENAME="myproject" bash "$BATS_TEST_DIRNAME/../scripts/decodie-gen-traefik.sh"
  [ -f "$tmpdir/.ddev/traefik/custom-global-config/decodie-myproject.yaml" ]
  grep -q "decodie.myproject.ddev.site" "$tmpdir/.ddev/traefik/custom-global-config/decodie-myproject.yaml"
  grep -q "8081" "$tmpdir/.ddev/traefik/custom-global-config/decodie-myproject.yaml"
  rm -rf "$tmpdir"
}

@test "decodie command exists and is executable" {
  [ -x "$BATS_TEST_DIRNAME/../commands/host/decodie" ]
}

@test "decodie command shows help" {
  run "$BATS_TEST_DIRNAME/../commands/host/decodie" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
  [[ "$output" == *"decodie.test-site.ddev.site"* ]]
}
