const express = require('express');
const next = require('next');
const helmet = require('helmet');
const logger = require('winston');

const routes = require('./src/routes');
const nextConfig = require('./next.config');

const { NODE_ENV, WEB_PORT: PORT } = process.env;

const app = next({ dir: './src', dev: NODE_ENV !== 'production', conf: nextConfig });

const handle = routes.getRequestHandler(app);

const server = express();

server.use(helmet()).use(handle);

app.prepare().then(() =>
  server.listen(PORT, (err) => {
    if (err) {
      throw err;
    }

    logger.info(`web server listening on port ${PORT} on ${NODE_ENV} mode`);
  }));
