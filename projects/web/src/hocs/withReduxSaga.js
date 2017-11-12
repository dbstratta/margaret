import React, { Component } from 'react';

/**
 * HOC that ends the saga in the server.
 */
export default WrappedPage =>
  class ReduxSagaWrapper extends Component {
    static getInitialProps(ctx) {
      if (ctx.isServer) {
        ctx.store.close();
      }

      return WrappedPage.getInitialProps ? WrappedPage.getInitialProps(ctx) : {};
    }

    render() {
      return <WrappedPage {...this.props} />;
    }
  };
