FROM node:9.2.1@sha256:ba200257c1386a50ffd73d2b137a996dc22e90dd87f47af3d289c76054b27700 AS builder

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY package.json yarn.lock ./
RUN yarn install

# Bundle app source.
COPY . .

RUN yarn build

FROM nginx:1.13.7

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/sites-available/margaret.conf
