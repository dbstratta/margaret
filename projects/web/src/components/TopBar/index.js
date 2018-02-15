import React from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

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

export const TopBar = () => (
  <StyledWrapper>
    <UpgradeWrapper>Upgrade</UpgradeWrapper>
    <LogoLink to="/">Margaret</LogoLink>
    <ButtonSet>Buttons</ButtonSet>
  </StyledWrapper>
);

export default TopBar;
