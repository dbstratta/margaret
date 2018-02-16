/**
 * The top bar of the site.
 */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Headroom from 'react-headroom';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

/**
 * When the headroom is scrolled we want it
 * to have a bottom shadow.
 */
const StyledHeadroom = styled(Headroom)`
  > .headroom.headroom--scrolled {
    box-shadow: 0px 2px 2px -2px rgba(0, 0, 0, 0.15);
  }
`;

const StyledWrapper = styled.div`
  --bar-height: 3.5rem;
  --grid-template-columns: 3fr 1fr;

  display: grid;
  grid-template-columns: var(--grid-template-columns);
  align-items: center;

  width: var(--main-content-width);
  height: var(--bar-height);

  margin: auto;

  @media (min-width: ${props => props.theme.breakpoints.lg}) {
    --bar-height: 4rem;
    --grid-template-columns: 1fr 3fr 1fr;
  }
`;

const UpgradeWrapper = styled.div`
  display: none;

  justify-self: start;

  @media (min-width: ${props => props.theme.breakpoints.lg}) {
    display: initial;
  }
`;

const LogoLink = styled(Link)`
  --justify-self: start;

  justify-self: var(--justify-self);

  @media (min-width: ${props => props.theme.breakpoints.lg}) {
    --justify-self: center;
  }
`;

const ButtonSet = styled.div`
  justify-self: end;
`;

export default class TopBar extends Component {
  static propTypes = { pinnable: PropTypes.bool };

  static defaultProps = { pinnable: true };

  state = {};

  render() {
    return (
      <StyledHeadroom disable={!this.props.pinnable}>
        <StyledWrapper>
          <UpgradeWrapper>Upgrade</UpgradeWrapper>
          <LogoLink to="/">Margaret</LogoLink>
          <ButtonSet>Buttons</ButtonSet>
        </StyledWrapper>
      </StyledHeadroom>
    );
  }
}
