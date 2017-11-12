import { makeExecutableSchema } from 'graphql-tools';

import RootQuery from './rootQuery';
import RootMutation from './rootMutation';
import RootSubscription from './rootSubscription';
import { gql } from './utils';

const SchemaDefinition = gql`
  schema {
    query: RootQuery
    mutation: RootMutation
    subscription: RootSubscription
  }
`;

const typeDefs = [SchemaDefinition, RootQuery, RootMutation, RootSubscription];

const resolvers = {};

export default makeExecutableSchema({
  typeDefs,
  resolvers,
});
