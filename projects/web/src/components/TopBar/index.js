import React from 'react';
import PropTypes from 'prop-types';
import Headroom from 'react-headroom';

export const TopBar = ({ hideable }) => <Headroom disable={!hideable}>Hola</Headroom>;

TopBar.propTypes = {
  hideable: PropTypes.bool,
};

TopBar.defaultProps = {
  hideable: false,
};

export default TopBar;
