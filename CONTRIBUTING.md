# Contributing to Margaret

We love pull requests from everyone. By participating in this project, you agree
to abide by its [code of conduct].

[code of conduct]: ./CODE_OF_CONDUCT.md

## Development setup

You'll need [Docker](https://docs.docker.com/engine/installation/) and
[Docker Compose](https://docs.docker.com/compose/install/).

1. Fork and clone the repo.
1. Get the containers running in the background with `docker-compose up -d`.
1. Enter the API container with `docker-compose exec api bash`.
1. Inside the container, create and migrate the database with `mix ecto.setup`.
1. Without leaving the container, run the Phoenix server with `mix phx.server`.

Now go to [http://margaret.localhost](http://margaret.localhost)
and check that you see the React app.

The GraphiQL playground is served at
[http://api.margaret.localhost/graphiql](http://api.margaret.localhost/graphiql).

Make sure to read the projects' READMEs before contributing:

* [api](./projects/api/README.md)
* [web](./projects/web/README.md)

### Creating a user

Inside the API container run `mix margaret.create_user`.
That'll return a JWT token for the user created that you can set in the GraphiQL playground
as the `Authorization` HTTP header. Like this: `Authorization: Bearer <token>`.

If the token expires or you want to get a new one you can use
`mix margaret.get_auth_token --username <username>`.
The command also accepts `--id <id>` and `--email <email>` variants.
