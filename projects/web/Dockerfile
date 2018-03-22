FROM node:9.9.0@sha256:bb58f67af7bc72d4cca048b1e30bc67c3f7b882e681edd9494a4bab57fa9421b AS builder

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

FROM nginx:1.13.10-alpine@sha256:8d5341da24ccbdd195a82f2b57968ef5f95bc27b3c3691ace0c7d0acf5612edd

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
