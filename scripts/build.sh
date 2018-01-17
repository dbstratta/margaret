#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG}" == "true" ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"

# Build the Docker images.
build() {
    local -r tag="${1}"; shift

    docker_compose_prod=docker-compose.yml:docker-compose.prod.yml

    # Build and tag the containers with the last git commit hash.
    COMPOSE_FILE="${docker_compose_prod}" TAG="${tag}" docker-compose build --no-cache "$@"

    # Build and tag the containers with "latest".
    # This second build should be much faster because it's cached.
    COMPOSE_FILE="${docker_compose_prod}" TAG="latest" docker-compose build "$@"
}

main() {
    build "$@"
}

# If executed as a script calls `main`, it doesn't otherwise.
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"