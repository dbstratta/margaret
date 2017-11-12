import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider, getDataFromTree } from 'react-apollo';
import Head from 'next/head';

import initApollo from '../initApollo';

export default WrappedPage =>
  class DataWrapper extends Component {
    static propTypes = { serverState: PropTypes.object.isRequired };

    static async getInitialProps(ctx) {
      let serverState = { apollo: {} };

      const wrappedInitialProps = WrappedPage.getInitialProps
        ? await WrappedPage.getInitialProps(ctx)
        : {};

      if (!process.browser) {
        const apollo = initApollo();

        try {
          const tree = (
            <ApolloProvider client={apollo}>
              <WrappedPage {...wrappedInitialProps} />
            </ApolloProvider>
          );
          await getDataFromTree(tree);
        } catch (e) {
          // eslint-disable-next-line no-console
          console.error(e);
        }

        Head.rewind();

        serverState = { apollo: { data: apollo.cache.extract() } };
      }

      return { serverState, ...wrappedInitialProps };
    }

    apollo = initApollo(this.props.serverState.apollo.data);

    render() {
      return (
        <ApolloProvider client={this.apollo}>
          <WrappedPage {...this.props} />
        </ApolloProvider>
      );
    }
  };
