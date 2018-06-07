FROM node:9.11.1@sha256:ec1bc675cbcb0c5215af40c7c1b7a8ea9d5f17b084eaf7b4b4e69e0963a38f26 AS builder

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

FROM nginx:1.14.0-alpine@sha256:b4f69b336db828ccdd0cdb6d3257f60cc8c5534cef6d08c2131d9a4950e893cf

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
