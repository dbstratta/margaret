FROM elixir:1.5.2 as base

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Install the hex package manager.
RUN mix local.hex --force

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
