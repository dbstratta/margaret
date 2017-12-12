FROM node:9.2.1@sha256:78f56003fff9b939dd34aff9fbd46c390802770953869db9b6b23086cc18b563 AS builder

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
RUN yarn install

# Bundle app source.
COPY . .

RUN yarn build

FROM nginx:1.13.7

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
