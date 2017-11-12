import { createServer } from 'http';

import Koa from 'koa';
import cors from 'kcors';
import helmet from 'koa-helmet';
import bodyParser from 'koa-bodyparser';
import koaLogger from 'koa-logger';
import { execute, subscribe } from 'graphql';
import logger from 'winston';

import router from './router';

const { NODE_ENV, API_PORT: PORT } = process.env;

const app = new Koa();

app
  .use(koaLogger())
  .use(bodyParser())
  .use(helmet())
  .use(cors())
  .use(router.routes())
  .use(router.allowedMethods());

const server = createServer(app.callback());

server.listen(PORT, (err) => {
  if (err) {
    throw err;
  }

  logger.info(`api server listening on port ${PORT} on ${NODE_ENV} mode`);
});
