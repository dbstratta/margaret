FROM elixir:1.5.2@sha256:f61284fbfea84603c61166f5443f484b6e427cdab21815e34357d6e535c6cd7b as base

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Install the hex package manager.
RUN mix local.hex --force

# We need Erlang's build tool too.
RUN mix local.rebar --force

RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Bundle app source.
COPY . .

RUN mix compile

CMD ["mix", "phx.server"]
