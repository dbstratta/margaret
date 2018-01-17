#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG}" == "true" ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
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