FROM node:9.1.0@sha256:89dcf2e2198a161086ed5df0e39bb81fd09b10283ebc0f9313f586466e88a0ba

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
