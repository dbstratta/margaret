import React, { Component } from 'react';
import { hoistStatics } from 'recompose';

/**
 * HOC that wraps a top-level page with an error boundary.
 */
export const withTopErrorBoundary = WrappedPage =>
  class TopErrorBoundary extends Component {
    state = { error: null };

    componentDidCatch(error) {
      this.setState({ error });
    }

    render() {
      if (this.state.error) {
        return null;
      }
      return <WrappedPage {...this.props} />;
    }
  };

export default hoistStatics(withTopErrorBoundary);
