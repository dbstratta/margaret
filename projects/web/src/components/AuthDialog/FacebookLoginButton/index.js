import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

const { API__FACEBOOK_CLIENT_ID: FACEBOOK_CLIENT_ID } = process.env;

const StyledLink = styled(Link)`
  background-color: hsla(221, 44%, 41%, 1);
`;

const getUrl = redirectUri =>
  `https://www.facebook.com/v2.11/dialog/oauth?client_id=${FACEBOOK_CLIENT_ID}&redirect_uri=${
    redirectUri
  }`;

const FacebookLoginButton = ({ redirectUri, children }) => (
  <StyledLink to={getUrl(redirectUri)}>{children}</StyledLink>
);

FacebookLoginButton.propTypes = {
  redirectUri: PropTypes.string.isRequired,
  children: PropTypes.any.isRequired,
};
