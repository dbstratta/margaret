FROM node:9.11.2@sha256:a18dcc02ca8e3eedd1b41a4085c3c506d785081e19c88df42f1c0c2ecdb098fc AS builder

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

FROM nginx:1.15.1-alpine@sha256:56a9367b64eaef37894842a6f7a19a0ef8e7bd5de964aa844a70b3e2d758033c

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
