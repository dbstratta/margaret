import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';

import { auth } from '../modules';

const mapStateToProps = state => ({ success: auth.selectors.getOauthCallbackSuccess(state) });
const mapDispatchToProps = { sendSocialLoginCode: auth.actions.sendSocialLoginCode };

export default function withAuth(WrappedComponent) {
  @withRouter
  @connect(mapStateToProps, mapDispatchToProps)
  class Auth extends PureComponent {
    static propTypes = {
      location: PropTypes.object.isRequired,
      success: PropTypes.bool.isRequired,
      sendSocialLoginCode: PropTypes.func.isRequired,
    };

    componentDidMount() {
      const { query } = this.state;
      const code = query.get('code');
      const provider = query.get('provider');

      if (code) {
        this.props.sendSocialLoginCode(provider, code);
      }
    }

    query = new URLSearchParams(this.props.location.search);
    redirectUrl = this.query.get('redirectUrl');

    render() {
      return <WrappedComponent success={this.props.success} redirectUrl={this.redirectUrl} />;
    }
  }

  return Auth;
}
