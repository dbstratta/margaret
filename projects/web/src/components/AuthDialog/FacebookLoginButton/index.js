import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

const { API__FACEBOOK_CLIENT_ID: FACEBOOK_CLIENT_ID } = process.env;

const StyledLink = styled(Link)`
  background-color: hsla(221, 44%, 41%, 1);
`;

const getFacebookOauthUrl = () =>
  `https://www.facebook.com/v2.11/dialog/oauth?client_id=${FACEBOOK_CLIENT_ID}&redirect_uri=${
    window.location.href
  }`;

export const FacebookLoginButton = ({ children }) => (
  <StyledLink to={getFacebookOauthUrl()}>{children}</StyledLink>
);

FacebookLoginButton.propTypes = {
  children: PropTypes.any.isRequired,
};

export default FacebookLoginButton;
