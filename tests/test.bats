#!/usr/bin/env bats

setup() {
  set -eu -o pipefail

  export GITHUB_REPO=owenbush/decodie-ddev

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  run ddev exec curl -s -o /dev/null -w '%{http_code}' http://localhost:8081
  assert_success
  assert_output "200"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

@test "addon files are installed correctly" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  assert_file_exist .ddev/config.decodie.yaml
  assert_file_exist .ddev/decodie/.env.example
  assert_file_exist .ddev/scripts/decodie-daemon.sh
  assert_file_executable .ddev/scripts/decodie-daemon.sh
  assert_file_exist .ddev/scripts/decodie-gen-traefik.sh
  assert_file_executable .ddev/scripts/decodie-gen-traefik.sh
  assert_file_exist .ddev/scripts/decodie-append-hostnames.sh
  assert_file_executable .ddev/scripts/decodie-append-hostnames.sh
}

@test "traefik config is generated" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  assert_file_exist "${HOME}/.ddev/traefik/custom-global-config/decodie-${PROJNAME}.yaml"
  run grep "decodie.${PROJNAME}.ddev.site" "${HOME}/.ddev/traefik/custom-global-config/decodie-${PROJNAME}.yaml"
  assert_success
}

@test "ddev decodie help works" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  run ddev decodie help
  assert_success
  assert_output --partial "Usage"
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
