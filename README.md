# Margaret

[![Travis branch](https://img.shields.io/travis/strattadb/margaret/develop.svg?style=flat-square)](https://travis-ci.org/strattadb/margaret)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

This is the umbrella repository of Margaret.

## Table of contents

* [Introduction](#introduction)
* [Features](#features)
* [Contributing](#contributing)
* [Project structure](#project-structure)
* [Projects](#projects)
* [License](#license)

## Introduction

Margaret is an open-source publishing platform (think of [Medium](https://medium.com)).
The initial scope is to implement the majority
of features Medium has. In the future, we'll implement features that will set Margaret apart.

## Features

* Authentication

  * [x] Users can sign up and sign in using their Facebook, Google and/or GitHub accounts

  * [ ] Users can sign in by clicking a magic link sent to their emails

* Stories

  * [x] Basic functionality

  * [ ] Views are counted

  * [ ] Users can publish monetized stories that only members can read

* Memberships

  * [ ] Users can opt in to our membership program

  * [ ] Members have access to a wider selection of stories

* Notifications

  * [x] Basic functionality

  * [x] Users can see only their notifications

  * [x] Users can mark a notification as read

  * [ ] Some notifications send emails

  * [ ] Real-time functionality

* Publications

  * [x] Basic functionality

  * [x] Admins can invite users to the publication

  * [x] Members of the publication can have different roles (writer, editor, etc)

  * [x] Writers can create drafts under the publication

  * [x] Editors can edit and publish drafts under the publication

* Recommendation system

  * [ ] The users' feeds are personalized based on their interests thanks to machine learning

* Follow system

  * [x] Basic functionality

  * [x] Users can follow other users and publications

* Star system

  * [x] Users can star stories and comments

* Bookmark system

  * [x] Users can bookmark stories and comments to read later

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

* [api](./projects/api): Margaret's main API (Elixir, Phoenix & Absinthe).
* [ml](./projects/ml): Machine learning predictions service (Django).
* [web](./projects/web): Web app (React).
* [mobile](./projects/mobile): Mobile app (React Native).

## Scripts

* [`build.sh`](./scripts/build.sh): Builds and tags the Docker images.

* [`deploy.sh`](./scripts/deploy.sh): Builds, tags and pushes the Docker images.

* [`gen_env_file.sh`](./scripts/gen_env_file.sh): Copies the example env file
  to the actual env file.

* [`push.sh`](./scripts/push.sh): Pushes the Docker images.

* [`test.sh`](./scripts/test.sh): Runs all the tests.

## License

[MIT](https://opensource.org/licenses/MIT)
