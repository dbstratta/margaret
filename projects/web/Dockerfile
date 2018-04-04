FROM node:9.10.1@sha256:0f2443df7bd7e207a32f3eb8f827fe2648152254cf02e5ecb3f30fc1c5e5659b AS builder

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

FROM nginx:1.13.11-alpine@sha256:e2d1ab469c1a398159bb5c7d4672bfebb8e607f35b465b00a4840c3853b703a1

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
