FROM node:9.5.0@sha256:9dbfb7a24c9afbbd0abfef08bf80e2ee5ac8033a0b184009c40a79194244e9a6 AS builder

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

FROM nginx:1.13.8-alpine@sha256:c8ff0187cc75e1f5002c7ca9841cb191d33c4080f38140b9d6f07902ababbe66

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
