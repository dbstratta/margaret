FROM elixir:1.5.2@sha256:82e47538ff83d1524d9a4bee5d52325ca6f9f428619dcd8531ac0f689df39b31 as base

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
