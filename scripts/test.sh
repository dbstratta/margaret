#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG:-false}" == "true" ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"

test() {
    # TODO: Implement this. 
}

main() {
    test "$@"
}

# If executed as a script calls `main`, it doesn't otherwise.
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"