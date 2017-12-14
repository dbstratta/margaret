FROM node:9.3.0@sha256:77f75d22a2a86619b50d073533dabdc4882508a39319018942b8759b844240c6 AS builder

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
