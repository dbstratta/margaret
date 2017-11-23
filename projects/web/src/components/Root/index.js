import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo';
import { Provider } from 'react-redux';
import { ConnectedRouter } from 'react-router-redux';
import { ThemeProvider } from 'styled-components';

import App from '../App';

const Root = ({ client, store, history }) => (
  <ApolloProvider client={client}>
    <Provider store={store}>
      <ConnectedRouter history={history}>
        <ThemeProvider theme={{}}>
          <App />
        </ThemeProvider>
      </ConnectedRouter>
    </Provider>
  </ApolloProvider>
);

Root.propTypes = {
  client: PropTypes.object.isRequired,
  store: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
};

export default Root;
