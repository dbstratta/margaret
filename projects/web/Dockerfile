FROM node:9.7.1@sha256:016052a6780d578fff9ac8822e66dd483db6ffb94573028b36cdd6ea48e98082 AS builder

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
