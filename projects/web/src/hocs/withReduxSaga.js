import React, { Component } from 'react';

import rootSaga from '../rootSaga';

/**
 * HOC that starts the root saga in the client.
 */
export default WrappedPage =>
  class ReduxSagaWrapper extends Component {
    static getInitialProps(ctx) {
      // Since we use GraphQL and Apollo, there's no need to run sagas in the server.
      if (!ctx.isServer) {
        ctx.store.runSaga(rootSaga);
      }

      return WrappedPage.getInitialProps ? WrappedPage.getInitialProps(ctx) : {};
    }

    render() {
      return <WrappedPage {...this.props} />;
    }
  };
