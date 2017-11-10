FROM node:9.1.0@sha256:cd6b6e2f0e71a1845462c939a8c713b648ae1b3e13f512ab3fc5944ebe7c30e5

LABEL name="margaret_web"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
RUN yarn

# Bundle app source.
COPY . .

USER node

EXPOSE 8090
CMD ["yarn", "start"]

