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

# Copies the example env file to `.env`.
gen_env_file() {
    local -r env_example_file="${__root}/.env.example"
    local -r env_file="${__root}/.env"

    cp "${env_example_file}" "${env_file}"
}

main() {
    gen_env_file
}

main