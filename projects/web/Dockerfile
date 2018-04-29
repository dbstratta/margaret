FROM node:9.11.1@sha256:2b90984bee6ff28f1f36daee3aae945d1c029d7c684dd223f9c3d22a52e5c01c AS builder

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

FROM nginx:1.13.12-alpine@sha256:3a44395131c5a9704417d19ab4c8d6cb104013659f5babb2f1c632e789588196

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
