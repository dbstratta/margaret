import React from 'react';
import PropTypes from 'prop-types';
import { Redirect } from 'react-router-dom';

import { withAuth } from '../../hocs';

export const OauthCallback = ({ redirectUrl }) => redirectUrl && <Redirect to={redirectUrl} />;

OauthCallback.propTypes = {
  redirectUrl: PropTypes.string.isRequired,
};

const enhance = withAuth;

export default enhance(OauthCallback);
