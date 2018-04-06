FROM node:9.10.1@sha256:aca3f9288813d657ba31c7788a14ff1fdebd35950dde2f3c3a1f040d27afa189 AS builder

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

FROM nginx:1.13.11-alpine@sha256:e0f3f5ebde753fa44b5fcdc771fc89f117ee8b2bbcece1c1bdf35f2de4da4e0b

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
