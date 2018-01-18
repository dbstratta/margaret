# Margaret

[![Travis branch](https://img.shields.io/travis/strattadb/margaret/develop.svg?style=flat-square)](https://travis-ci.org/strattadb/margaret)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

This is the umbrella repository of Margaret.

## Table of contents

* [Introduction](#introduction)
* [Contributing](#contributing)
* [Project structure](#project-structure)
* [Projects](#projects)
* [License](#license)

## Introduction

Margaret is an open-source publishing platform (think of [Medium](https://medium.com)).
The initial scope is to implement the majority
of features Medium has. In the future, we'll implement features that will set Margaret apart.

## Contributing

Please see [CONTRIBUTING](./CONTRIBUTING.md).

## Project structure

* [**`__tests__`**](./__tests__): Contains end-to-end tests written in JavaScript with Jest.

* [**`.github`**](./.github): Contains GitHub template files.

* [**`.vscode`**](./.vscode): Contains VSCode workspace configuration files.

* [**`k8s`**](./k8s): Contains Kubernetes manifests for production deployment.

* [**`projects`**](./projects): Contains the projects Margaret consist of.

* [**`scripts`**](./scripts): Contains useful scripts for CI and other things.

## Projects

* [api](./projects/api): GraphQL API.
* [web](./projects/web): React app.

## Scripts

* [`build.sh`](./scripts/build.sh): Builds and tags the Docker images.

* [`deploy.sh`](./scripts/deploy.sh): Builds, tags and pushes the Docker images.

* [`gen_env_file.sh`](./scripts/gen_env_file.sh): Copies the example env file
  to the actual env file.

* [`push.sh`](./scripts/push.sh): Pushes the Docker images.

* [`test.sh`](./scripts/test.sh): Runs all the tests.

## License

[MIT](https://opensource.org/licenses/MIT)
