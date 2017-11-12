import Router from 'koa-router';
import { graphqlKoa, graphiqlKoa } from 'apollo-server-koa';

const { NODE_ENV } = process.env;

const router = new Router();

const GRAPHQL_ENDPOINT = '/graphql';
const GRAPHIQL_ENDPOINT = '/graphiql';

export default router.all(GRAPHQL_ENDPOINT, graphqlKoa({ schema }));

// For the time being, we don't want GraphiQL in production.
if (NODE_ENV !== 'production') {
  router.get(GRAPHIQL_ENDPOINT, graphiqlKoa({ endpointURL: GRAPHQL_ENDPOINT }));
}
