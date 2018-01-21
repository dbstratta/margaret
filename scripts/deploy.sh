#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG:-false}" == "true" ]] && set -o xtrace

# Build images and pushes them to the registry.
deploy() {
    local -r tag="${1}"; shift

    build_images "${tag}"
    push_images
}

main() {
    local -r __script_path="${BASH_SOURCE[0]}"
    local -r __dir="$(cd "$(dirname "${__script_path}")" && pwd)"
    local -r __file="${__dir}/$(basename "${__script_path}")"
    local -r __base="$(basename ${__file} .sh)"
    local -r __root="$(cd "$(dirname "${__dir}")" && pwd)"

    source "${__dir}/build.sh"
    source "${__dir}/push.sh"

    deploy "$@"
}

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi