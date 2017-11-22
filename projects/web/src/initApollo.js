import { ApolloClient } from 'apollo-client';
import { HttpLink } from 'apollo-link-http';
import { InMemoryCache } from 'apollo-cache-inmemory';
import fetch from 'isomorphic-unfetch';

let apolloClient = null;

const URI = 'http://api:8080/graphql';

// We need `fetch` in the server too.
if (!process.browser) {
  global.fetch = fetch;
}

const createApolloClient = (initialState = {}) =>
  new ApolloClient({
    connectToDevTools: process.browser,
    ssrMode: !process.browser,
    link: new HttpLink({
      uri: URI,
      credentials: true,
      headers: {
        // We put this custom header to prevent CSRF attacks.
        'X-Requested-With': 'XMLHttpRequest',
      },
    }),
    cache: new InMemoryCache().restore(initialState),
  });

export default function initApollo(initialState) {
  // We want to create a new Apollo client for every request in the server,
  // otherwise, we would share data between different users.
  if (!process.browser) {
    return createApolloClient(initialState);
  }

  // In the client reuse the same Apollo client.
  if (!apolloClient) {
    apolloClient = createApolloClient(initialState);
  }

  return apolloClient;
}
