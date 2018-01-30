FROM elixir:1.6.1@sha256:e3140363117014ffa718e9c05e97e7a0dc77e7efbf648bd0de760173b7e5e082

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
