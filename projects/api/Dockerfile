# Build stage
FROM elixir:1.6.4-alpine@sha256:c2cc196a6dcba395c1ffbeb1f4ebb85d4f89b874aa20d18ba313c9520da534e5 AS builder

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
FROM alpine:3.7@sha256:7b848083f93822dd21b0a2f14a110bd99f6efb4b838d499df6d04a49d0debf8b

ENV MIX_ENV=${MIX_ENV:-prod} REPLACE_OS_VARS=true

WORKDIR /opt/app

# Copy the artifacts from the builder stage.
COPY --from=builder /opt/release .

CMD ["./bin/start_server", "foreground"]
