FROM node:9.2.0@sha256:2eaba9581104073df5c6b27709d43a47ec09925fad53337d7c2eee5829cf358f

LABEL name="margaret_web"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
RUN yarn install --production

# Bundle app source.
COPY . .

USER node

EXPOSE 8090
CMD ["yarn", "start"]
