FROM node:9.5.0

LABEL name="margaret_web_dev"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
RUN yarn install

# Bundle app source.
COPY . .

EXPOSE 3000
CMD ["yarn", "start"]
