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

# Pushes the Docker images to the registry (Docker Hub).
push() {
    docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}"

    docker-compose push
}

main() {
    push "$@"
}

# If executed as a script calls `main`, it doesn't otherwise.
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"