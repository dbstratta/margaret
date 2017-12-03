import React from 'react';
import PropTypes from 'prop-types';
import { branch, renderComponent } from 'recompose';
import { Redirect } from 'react-router-dom';
import { compose } from 'ramda';

import { withAuth } from '../../hocs';

export const OauthCallback = ({ redirectUrl }) => <Redirect to={redirectUrl} />;

OauthCallback.propTypes = {
  redirectUrl: PropTypes.string.isRequired,
};

const withLoading = branch(({ success }) => success, renderComponent(OauthCallback));

const enhance = compose(withAuth, withLoading);

export default enhance(OauthCallback);
