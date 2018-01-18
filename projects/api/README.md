# Margaret API

## Table of contents

* [Introduction](#introduction)
* [Project structure](#project-structure)

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

* [**`config`**](./config): Contains the configuration files for the Elixir application
  for different environments.

* [**`lib`**](./lib): Contains the source code.

  * [**`margaret`**](./lib/margaret): Contains the business logic and storage details.
    Each folder is a context.

  * [**`margaret_web`**](./lib/margaret_web): Contains all the modules related to the web layer.

    * [**`channels`**](./lib/margaret_web/channels): Contains Phoenix channels.

    * [**`controllers`**](./lib/margaret_web/controllers): Contains web controllers and actions.
      Since we are building a GraphQL application we don't use controllers, we use resolvers.
      But some functionality has to be outside of GraphQL. Oauth2 sign in, for example.

    * [**`helpers`**](./lib/margaret_web/helpers): Contains modules with helper functions.

    * [**`middleware`**](./lib/margaret_web/middleware): Contains GraphQL middleware.

    * [**`pipelines`**](./lib/margaret_web/pipelines): Contains Plug custom pipelines.

    * [**`resolvers`**](./lib/margaret_web/resolvers): Contains GraphQL resolvers.

    * [**`schema`**](./lib/margaret_web/resolvers): Contains Graphql type, query,
      mutation and subscription definitions.

    * [**`views`**](./lib/margaret_web/views): Contains Phoenix views. We don't use them though.

    * [**`workers`**](./lib/margaret_web/workers): Contains workers that perform
      tasks enqueued with `Exq`.

    * [`context.ex`](./lib/margaret_web/context.ex): Builds the GraphQL context
      from data from each request.
      Here we put the user struct in the context if the viewer is logged in, for example.

    * [`endpoint.ex`](./lib/margaret_web/endpoint.ex): The Phoenix endpoint.

    * [`guardian.ex`](./lib/margaret_web/guardian.ex): Callback module for `Guardian`.

    * [`helpers.ex`](./lib/margaret_web/helpers.ex): Helper functions.

    * [`router.ex`](./lib/margaret_web/router.ex): The Phoenix router.

    * [`schema.ex`](./lib/margaret_web/schema.ex): The GraphQL schema definition.

  * [**`mix`**](./lib/mix): Contains modules related to the Mix build system.

    * [**`tasks`**](./lib/mix/tasks): Contains custom Mix tasks.

* [**`priv`**](./priv):

  * [**`repo`**](./priv/repo):

    * [**`migrations`**](./priv/repo/migrations): Contains all the database migration files.

    * [`seeds.ex`](./priv/repo/seeds.exs): Contains the initial data to populate the database with.

* [**`test`**](./test): Contains all the tests.
