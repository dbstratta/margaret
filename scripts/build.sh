#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG:-false}" == "true" ]] && set -o xtrace

# Build the Docker images.
build_images() {
    local -r tag="${1}"; shift

    local -r docker_compose_prod=docker-compose.yml:docker-compose.prod.yml

    # Build and tag the containers with the last git commit hash.
    # COMPOSE_FILE="${docker_compose_prod}" TAG="${tag}" docker-compose build --no-cache "$@"

    # Build and tag the containers with "latest".
    # This second build should be much faster because it's cached.
    COMPOSE_FILE="${docker_compose_prod}" TAG=latest docker-compose build "$@"
}

main() {
    local -r __script_path="${BASH_SOURCE[0]}"
    local -r __dir="$(cd "$(dirname "${__script_path}")" && pwd)"
    local -r __file="${__dir}/$(basename "${__script_path}")"
    local -r __base="$(basename ${__file} .sh)"
    local -r __root="$(cd "$(dirname "${__dir}")" && pwd)"

    build_images "$@"
}

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi