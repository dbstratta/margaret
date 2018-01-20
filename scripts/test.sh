#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG:-false}" == "true" ]] && set -o xtrace

readonly __script_path="${BASH_SOURCE[0]}"
readonly __dir="$(cd "$(dirname "${__script_path}")" && pwd)"
readonly __file="${__dir}/$(basename "${__script_path}")"
readonly __base="$(basename ${__file} .sh)"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"

test() {
    local -r docker_compose_test=docker-compose.yml:docker-compose.test.yml

    # Code style checks

    COMPOSE_FILE="${docker_compose_test}" docker-compose run api mix format --check-formatted

    # Tests

    yarn test

    COMPOSE_FILE="${docker_compose_test}" docker-compose run api mix test
    COMPOSE_FILE="${docker_compose_test}" docker-compose run web yarn test
}

main() {
    test "$@"
}

# If executed as a script calls `main`, it doesn't otherwise.
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"