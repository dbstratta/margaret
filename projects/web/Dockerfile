FROM node:9.11.1@sha256:e9311a4a7beacb1e655b459d1320931a87ccb69ece3bfa6444928c24173bb992 AS builder

ENV NODE_ENV=${NODE_ENV:-production}

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
# We need `react-app-rewired` to build the app
# and it's listed in `devDependencies`. That's why
# we pass `--production=false`.
RUN yarn install --production=false

# Bundle app source.
COPY . .

RUN yarn build

FROM nginx:1.15.0-alpine@sha256:d773c869aa64a3a0f8e49374a3270ba0ff8ac6ba149b1e9bca713ac708051f79

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
