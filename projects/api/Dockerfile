# Build stage
FROM elixir:1.6.5-alpine@sha256:90d17c8b4a0af4800e1ded09791cf8b041cc6b568de28fb2dd5f29908d97b3e9 AS builder

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
FROM alpine:3.7@sha256:8c03bb07a531c53ad7d0f6e7041b64d81f99c6e493cb39abba56d956b40eacbc

ENV MIX_ENV=${MIX_ENV:-prod} REPLACE_OS_VARS=true

WORKDIR /opt/app

# Copy the artifacts from the builder stage.
COPY --from=builder /opt/release .

CMD ["./bin/start_server", "foreground"]
