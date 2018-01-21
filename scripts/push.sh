#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ "${DEBUG:-false}" == "true" ]] && set -o xtrace

# Pushes the Docker images to the registry (Docker Hub).
push_images() {
    echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin

    local -r docker_compose_prod=docker-compose.yml:docker-compose.prod.yml

    COMPOSE_FILE="${docker_compose_prod}" TAG=latest docker-compose push
}

main() {
    local -r __script_path="${BASH_SOURCE[0]}"
    local -r __dir="$(cd "$(dirname "${__script_path}")" && pwd)"
    local -r __file="${__dir}/$(basename "${__script_path}")"
    local -r __base="$(basename ${__file} .sh)"
    local -r __root="$(cd "$(dirname "${__dir}")" && pwd)"

    push_images "$@"
}

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi