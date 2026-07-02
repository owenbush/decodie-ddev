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

@test "install.yaml installs decodie-ui@latest" {
  grep -q "@owenbush/decodie-ui@latest" "$BATS_TEST_DIRNAME/../install.yaml"
}

@test "install.yaml installs skills globally" {
  grep -q "skills add owenbush/decodie-skill --all -g" "$BATS_TEST_DIRNAME/../install.yaml"
}

@test "install.yaml preserves existing .env" {
  grep -q 'if \[ ! -f decodie/.env \]' "$BATS_TEST_DIRNAME/../install.yaml"
}

@test "config.decodie.yaml defines web_extra_daemons" {
  [ -f "$BATS_TEST_DIRNAME/../config.decodie.yaml" ]
  grep -q "web_extra_daemons" "$BATS_TEST_DIRNAME/../config.decodie.yaml"
  grep -q "decodie" "$BATS_TEST_DIRNAME/../config.decodie.yaml"
}

@test "config.decodie.yaml post-start installs latest decodie-ui" {
  grep -q "@owenbush/decodie-ui@latest" "$BATS_TEST_DIRNAME/../config.decodie.yaml"
}

@test "traefik script generates correct config" {
  tmpdir=$(mktemp -d)
  HOME="$tmpdir" DDEV_SITENAME="myproject" bash "$BATS_TEST_DIRNAME/../scripts/decodie-gen-traefik.sh"
  [ -f "$tmpdir/.ddev/traefik/custom-global-config/decodie-myproject.yaml" ]
  grep -q "decodie.myproject.ddev.site" "$tmpdir/.ddev/traefik/custom-global-config/decodie-myproject.yaml"
  grep -q "8081" "$tmpdir/.ddev/traefik/custom-global-config/decodie-myproject.yaml"
  rm -rf "$tmpdir"
}

@test "hostname append script requires DDEV_SITENAME" {
  unset DDEV_SITENAME
  run bash "$BATS_TEST_DIRNAME/../scripts/decodie-append-hostnames.sh"
  [ "$status" -ne 0 ]
}

@test "daemon script exists and is executable" {
  [ -x "$BATS_TEST_DIRNAME/../scripts/decodie-daemon.sh" ]
}

@test "daemon script serves on port 8081" {
  grep -q "8081" "$BATS_TEST_DIRNAME/../scripts/decodie-daemon.sh"
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

@test "decodie command rejects unknown subcommands" {
  run "$BATS_TEST_DIRNAME/../commands/host/decodie" nonsense
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown command"* ]]
}

@test ".env.example exists" {
  [ -f "$BATS_TEST_DIRNAME/../decodie/.env.example" ]
}

@test ".gitignore excludes .env and node_modules" {
  grep -q "^\.env$" "$BATS_TEST_DIRNAME/../decodie/.gitignore"
  grep -q "^node_modules/" "$BATS_TEST_DIRNAME/../decodie/.gitignore"
}
