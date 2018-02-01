FROM elixir:1.6.1@sha256:12d53653915bae271eee11d84147e4f6501d18dec9d405eba9204ff7b06d2b63

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
