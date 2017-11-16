FROM node:9.2.0@sha256:7c9099e0f68242387d7755eaa54c287e16cedd3cca423444ca773794f5f1e423

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
