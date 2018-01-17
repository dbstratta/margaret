#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG}" == "true" ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"

source build.sh
source push.sh

deploy() {
    local -r tag="${1}"; shift

    build tag
    push
}

main() {
    deploy "$@"
}

# If executed as a script calls `main`, it doesn't otherwise.
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"