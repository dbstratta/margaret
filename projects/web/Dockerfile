FROM node:9.11.1@sha256:8a4ad1abc3fcec3fc2d75420dfb5e7d042768ad6b60cab3a98a7450ec8be8915 AS builder

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

FROM nginx:1.13.12-alpine@sha256:4b1e3a730525e9f73231c0e643dc3111133c352b7dcb02c32723560caa59da19

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
