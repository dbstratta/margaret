FROM elixir:1.6.1

LABEL name="margaret_api_dev"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Install `inotify-tools` to enable Phoenix's live reloading.
RUN apt-get update && apt-get -y install inotify-tools && \
    # Install the Hex package manager.
    mix local.hex --force && \
    # Install Erlang's build tool.
    mix local.rebar --force && \
    # Install Phoenix.
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile

# Bundle app source.
COPY . .

RUN mix compile

CMD ["mix", "phx.server"]
