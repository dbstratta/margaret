import React from 'react';
import PropTypes from 'prop-types';
import Headroom from 'react-headroom';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

const StyledWrapper = styled.div`
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-between;
  width: 100%;
  margin: auto;

  @media (min-width: ${props => props.theme.breakpoints.lg}px) {
    width: 80%;
  }
`;

const UpgradeWrapper = styled.div`
  display: none;

  @media (min-width: ${props => props.theme.breakpoints.lg}px) {
    display: initial;
    flex: 1 1 20%;
    text-align: center;
  }
`;

const LogoLink = styled(Link)`
  flex: 1 1 60%;

  @media (min-width: ${props => props.theme.breakpoints.lg}px) {
    text-align: center;
  }
`;

const ButtonSet = styled.div`
  flex: 1 1 20%;
  text-align: center;
`;

export const TopBar = ({ hideable }) => (
  <Headroom disable={!hideable}>
    <StyledWrapper>
      <UpgradeWrapper>Upgrade</UpgradeWrapper>
      <LogoLink to="/">Margaret</LogoLink>
      <ButtonSet>Buttons</ButtonSet>
    </StyledWrapper>
  </Headroom>
);

TopBar.propTypes = {
  hideable: PropTypes.bool,
};

TopBar.defaultProps = {
  hideable: false,
};

export default TopBar;
