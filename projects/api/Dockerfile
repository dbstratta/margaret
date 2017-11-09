FROM node:9.1.0@sha256:975dcd16d62d0155a9edd614cd89b1599661dd57777ed39b862f44e4a6a9d6f6

LABEL name="margaret_api"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

USER node

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
RUN yarn

# Bundle app source.
COPY . .

EXPOSE 8080
CMD ["yarn", "start"]
