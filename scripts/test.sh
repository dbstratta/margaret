#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG:-false}" == "true" ]] && set -o xtrace

# Run tests.
run_tests() {
    # Code style and lint checks

    docker-compose run --rm api mix format --check-formatted
    # docker-compose run --rm api mix credo

    # Tests

    # yarn test

    docker-compose run --rm api mix test
    docker-compose run --rm web yarn test
}

main() {
    local -r __script_path="${BASH_SOURCE[0]}"
    local -r __dir="$(cd "$(dirname "${__script_path}")" && pwd)"
    local -r __file="${__dir}/$(basename "${__script_path}")"
    local -r __base="$(basename ${__file} .sh)"
    local -r __root="$(cd "$(dirname "${__dir}")" && pwd)"

    run_tests "$@"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
