import React from 'react';
import PropTypes from 'prop-types';
import { branch, renderComponent, renderNothing } from 'recompose';
import { Redirect } from 'react-router-dom';
import { compose } from 'ramda';

import { withAuth } from '../../hocs';

export const OauthCallback = ({ redirectUrl }) => <Redirect to={redirectUrl} />;

OauthCallback.propTypes = {
  redirectUrl: PropTypes.string.isRequired,
};

const redirectIfError = branch(({ error }) => error, renderNothing, renderComponent(OauthCallback));

const enhance = compose(withAuth, redirectIfError);

export default enhance(OauthCallback);
