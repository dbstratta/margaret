FROM elixir:1.6.0@sha256:0c36c7cf3368e44c514531b90e7e3aa4c17f3179a60a6a3ea6c2ebc4dc21f52b

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

ENV MIX_ENV=${MIX_ENV:-prod}

# Install the Hex package manager.
RUN mix local.hex --force && \
    # Install Erlang's build tool.
    mix local.rebar --force && \
    # Install Phoenix.
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
