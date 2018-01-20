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

source "${__dir}/build.sh"
source "${__dir}/push.sh"

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