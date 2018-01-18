FROM elixir:1.6.0@sha256:c49d02f8aefff38d07bfc11d05c64f29b6ae01273b8ff1aab500683ac6e8fdc1 as base

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
