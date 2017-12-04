import React, { PureComponent } from 'react';

import { auth } from '../api';
import { auth as authUtils } from '../utils';

export default WrappedComponent =>
  class Auth extends PureComponent {
    state = {
      success: false,
      loading: false,
      error: null,
    };

    /* eslint-disable react/no-did-mount-set-state */
    async componentDidMount() {
      const { query } = this;
      const code = query.get('code');
      const provider = query.get('provider');

      if (code) {
        try {
          this.setState({ loading: true });
          const token = await auth.sendSocialLoginCode(provider, code);
          authUtils.setToken(token);
          this.setState({ success: true, loading: false });
        } catch (error) {
          this.setState({ success: false, error, loading: false });
        }
      }
    }
    /* eslint-enable react/no-did-mount-set-state */

    query = new URLSearchParams(window.location.search);
    redirectUrl = this.query.get('redirectUrl');

    render() {
      return (
        <WrappedComponent
          success={this.state.success}
          loading={this.state.loading}
          error={this.state.error}
          redirectUrl={this.redirectUrl}
        />
      );
    }
  };
