FROM node:9.11.2@sha256:cddc729ef8326f7e8966c246ba2e87bad4c15365494ff3d681fa6f022cdab041 AS builder

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

FROM nginx:1.15.1-alpine@sha256:666da0588d2121ff83bc273376ce3fa98c18904b4dd6664bf0992278a2e96ae3

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
