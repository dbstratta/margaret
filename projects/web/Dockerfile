FROM node:9.2.0@sha256:1311f9b826406e2bdc275f5dc3daf5a20ccf047b5508e3e29007d631c68edd2a

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
