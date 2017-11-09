FROM node:9.1.0@sha256:75f50fb3fc9a18481b51f920fa7e2881f198992c6f651aac12e390247d436ea9

LABEL name="margaret_web"
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

EXPOSE 8090
CMD ["yarn", "start"]
