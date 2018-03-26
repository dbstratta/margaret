FROM node:9.9.0@sha256:2d15ad96d643729ba70f50d9c5890181e18d98b7a95b5c303637b58daf8fc492 AS builder

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

FROM nginx:1.13.10-alpine@sha256:17c4704e19a11cd47545fa3c17e6903fc88672021f7f907f212d6663baf6ab57

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
