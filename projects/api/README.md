# Margaret API

## Table of contents

* [Introduction](#introduction)
* [Project Structure](#project-structure)

## Introduction

The Margaret API is a GraphQL API built with
[Elixir](https://elixir-lang.org/),
[Phoenix](https://hexdocs.pm/phoenix/overview.html),
[Ecto](https://hexdocs.pm/ecto/Ecto.html),
[Absinthe](https://hexdocs.pm/absinthe/overview.html)
and [Absinthe Relay](https://hexdocs.pm/absinthe_relay/Absinthe.Relay.html).

For background tasks we use [Exq](https://hexdocs.pm/exq/readme.html).

We try to comply with the
[Relay Graphql Server Specification](https://facebook.github.io/relay/docs/en/graphql-server-specification.html) whenever possible.

## Project structure

* **`config`**: Contains the configuration files for the Elixir application
  for different environments.

* **`lib`**: Contains the source code.

  * **`margaret`**: Contains the business logic and storage details.
    Each folder is a context.

  * **`margaret_web`**: Contains the all the modules related to the web layer.

    * **`channels`**: Contains Phoenix channels.

    * **`controllers`**: Contains web controllers and actions.
      Since we are building a GraphQL application we don't use controllers, we use resolvers.
      But some functionality has to be outside of GraphQL. Oauth2 sign in, for example.

    * **`helpers`**: Contains modules with helper functions.

    * **`middleware`**: Contains GraphQL middleware.

    * **`pipelines`**: Contains Plug custom pipelines.

    * **`resolvers`**: Contains GraphQL resolvers.

    * **`schema`**: Contains Graphql type, query, mutation and subscription definitions.

    * **`views`**: Contains Phoenix views. We don't use them though.

    * **`workers`**: Contains workers that perform tasks enqueued with `Exq`.

    * `context.ex`: Builds the GraphQL context from data from each request.
      Here we put the user struct in the context if the viewer is logged in, for example.

    * `endpoint.ex`: The Phoenix endpoint.

    * `guardian.ex`: Callback module for `Guardian`.

    * `helpers.ex`: Helper functions.

    * `router.ex`: The Phoenix router.

    * `schema.ex`: The GraphQL schema definition.

  * **`mix`**: Contains modules related to the Mix build system.

    * **`tasks`**: Contains custom Mix tasks.

* **`priv`**:

  * **`repo`**: Contains all the database migration files.

  * `seeds.ex`: Contains the initial data to populate the database with.

* **`test`**: Contains all the tests.
