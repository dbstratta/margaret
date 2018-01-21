FROM elixir:1.6.0@sha256:c49d02f8aefff38d07bfc11d05c64f29b6ae01273b8ff1aab500683ac6e8fdc1

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

ENV MIX_ENV=${MIX_ENV:-prod}

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile

# Bundle app source.
COPY . .

RUN mix compile

CMD ["mix", "phx.server"]
