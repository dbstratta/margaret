FROM node:9.2.1@sha256:998b099a9790327db5c2808b162862accc609f4ef96de53fbf77b468d2a9ffdb AS builder

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
