import React from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

const StyledNav = styled.nav`
  position: sticky;
  top: 0;

  ${props => props.theme.spacing.paddingTopBottom('sm')};
`;

const StyledUl = styled.ul`
  list-style: none;

  padding: 0;
  margin: 0;
`;

const StyledLi = styled.li``;

const TopicBar = () => (
  <StyledNav>
    <StyledUl>
      <StyledLi>
        <Link to="/">Home</Link>
      </StyledLi>
      <StyledLi>
        <Link to="/">Pepe</Link>
      </StyledLi>
    </StyledUl>
  </StyledNav>
);

export default TopicBar;
