FROM elixir:1.5.2

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Install `inotify-tools` to enable Phoenix's live reloading.
RUN apt-get update && apt-get -y install inotify-tools

# Install the hex package manager.
RUN mix local.hex --force

# We need Erlang's build tool too.
RUN mix local.rebar --force

RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

# Bundle app source.
COPY . .

CMD ["mix", "phx.server"]
