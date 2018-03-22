FROM node:9.9.0@sha256:0b98790825931cfb0c2d6c07ec70d02e90dfac7054121e5cd16a39cb64fa8157 AS builder

ENV NODE_ENV=${NODE_ENV:-production}

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
# We need `react-app-rewired` to build the app
# and it's listed in `devDependencies`. That's why
# we pass `--production=false`.
RUN yarn install --production=false

# Bundle app source.
COPY . .

RUN yarn build

FROM nginx:1.13.9-alpine@sha256:48947591194ac5a9dce1e110f9198a547debb21630f121081640b87d99ca8b11

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
