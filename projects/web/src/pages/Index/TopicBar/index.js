/**
 * The TopicBar is the bar displayed below the main bar
 * and has a list of links to story topics.
 */

import React, { Component, Fragment } from 'react';
import { Link } from 'react-router-dom';
import Observer from '@researchgate/react-intersection-observer';
import styled from 'styled-components';

const StyledNav = styled.nav`
  --bottom-shadow: 0px 2px 2px -2px rgba(0, 0, 0, 0.25);

  position: sticky;
  top: 0;

  box-shadow: ${({ bottomShadow }) => (bottomShadow ? 'var(--bottom-shadow)' : 'none')};
`;

const StyledUl = styled.ul`
  display: grid;

  list-style: none;
  padding: 0;
  margin: 0;
`;

const StyledLi = styled.li`
  margin: 0 ${props => props.theme.spacing.sizes.sm};
`;

/**
 * The IntersectionObserver (the <Observer /> React element)
 * needs an element to observe.
 * The sentinel fulfills this need.
 *
 * Why do we need a sentinel?
 *
 * Because we want to add a shadow to the topic bar when
 * it gets stuck to the top of the screen (using position: sticky),
 * so the only clean way to do that is to place a sentinel right
 * before the topic bar (as a sibling) and observe its intersection
 * state with the viewport. If the sentinel is not shown on screen then
 * it means that the topic bar is stuck to the top. If the sentinel is
 * shown, it means that the topic bar isn't stuck.
 */
const Sentinel = styled.div`
  visibility: hidden;
`;

/**
 * The links to show in the topic bar.
 */
const topics = [
  { path: '/', topic: 'Home' },
  { path: '/', topic: 'Technology' },
  { path: '/', topic: 'Culture' },
];

const renderTopics = topicList =>
  topicList.map(({ path, topic }) => (
    <StyledLi>
      <Link to={path}>{topic}</Link>
    </StyledLi>
  ));

export default class TopicBar extends Component {
  state = { bottomShadow: false };

  /**
   * Callback that is called when the sentinel
   * (the element the IntersectionObserver is observing)
   * changes its intersection state with respect to the viewport.
   */
  handleIntersectionChange = ({ isIntersecting }) =>
    this.setState({ bottomShadow: !isIntersecting });

  render() {
    return (
      <Fragment>
        <Observer onChange={this.handleIntersectionChange}>
          <Sentinel />
        </Observer>
        <StyledNav bottomShadow={this.state.bottomShadow}>
          <StyledUl>{renderTopics(topics)}</StyledUl>
        </StyledNav>
      </Fragment>
    );
  }
}
