# Build stage
FROM elixir:1.6.6-alpine@sha256:aca66e7bf05b927484c3754684a903e7441bb474ae6e2e89dabd3bd4cfc0f6fd AS builder

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

ARG APP_NAME=margaret
ENV MIX_ENV=${MIX_ENV:-prod} REPLACE_OS_VARS=true

# Install the Hex package manager.
RUN mix local.hex --force && \
    # Install Erlang's build tool.
    mix local.rebar --force

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod \
    , deps.compile

# Bundle app source.
COPY . .

RUN mix do compile \
    , release --env=prod --verbose \
    # Alpine Linux doesn't come with the /opt folder.
    && mkdir -p /opt \
    && mv _build/prod/rel/${APP_NAME} /opt/release \
    && mv /opt/release/bin/${APP_NAME} /opt/release/bin/start_server

# Final stage
FROM alpine:3.11@sha256:ddba4d27a7ffc3f86dd6c2f92041af252a1f23a8e742c90e6e1297bfa1bc0c45

ENV MIX_ENV=${MIX_ENV:-prod} REPLACE_OS_VARS=true

WORKDIR /opt/app

# Copy the artifacts from the builder stage.
COPY --from=builder /opt/release .

CMD ["./bin/start_server", "foreground"]
