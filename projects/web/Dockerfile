FROM node:9.3.0@sha256:777bec4a51f42761d5940cbb6f4dd9b5272952189439debb2812bd8eae64a5e5 AS builder

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
