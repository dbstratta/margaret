import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';

import { auth } from '../modules';

const mapDispatchToProps = { sendSocialLoginCode: auth.actions.sendSocialLoginCode };

export default function withAuth(WrappedComponent) {
  @withRouter
  @connect(null, mapDispatchToProps)
  class Auth extends PureComponent {
    static propTypes = {
      location: PropTypes.object.isRequired,
      sendSocialLoginCode: PropTypes.func.isRequired,
    };

    componentDidMount() {
      const query = new URLSearchParams(this.props.location.search);
      const code = query.get('code');
      const provider = query.get('provider');

      if (code) {
        this.props.sendSocialLoginCode(provider, code);
      }
    }

    render() {
      return <WrappedComponent {...this.props} />;
    }
  }

  return Auth;
}
