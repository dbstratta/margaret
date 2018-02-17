/**
 * The TopicBar is the bar displayed below the main bar
 * and has a list of links to story topics.
 */

import React, { Component, Fragment } from 'react';
import { NavLink } from 'react-router-dom';
import Observer from '@researchgate/react-intersection-observer';
import styled from 'styled-components';

const StyledNav = styled.nav`
  --nav-height: 2.5rem;
  --bottom-shadow: 0px 2px 2px -2px rgba(0, 0, 0, 0.15);

  position: sticky;
  top: 0;
  height: var(--nav-height);

  background-color: var(--background-color);

  box-shadow: ${({ bottomShadow }) => (bottomShadow ? 'var(--bottom-shadow)' : 'none')};

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    --nav-height: 3.1rem;
  }
`;

const NavWrapper = styled.div`
  display: flex;
  align-items: center;

  width: var(--main-content-width);
  height: 100%;

  margin: auto;
`;

const NavControl = styled.button`
  display: none;

  border: none;

  margin-right: ${({ left }) => (left ? 'var(--sm-space)' : 0)};
  margin-left: ${({ right }) => (right ? 'var(--sm-space)' : 0)};

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    display: initial;
  }
`;

const TopicListWrapper = styled.div`
  height: inherit;

  overflow: scroll;
  scroll-behavior: smooth;
`;

const TopicList = styled.ul`
  display: grid;
  grid-auto-flow: column;
  grid-auto-columns: auto;
  grid-gap: 1.5rem;
  justify-items: center;
  align-items: center;

  height: inherit;

  padding: 0;
  margin: 0;

  list-style: none;
`;

const StyledItem = styled.li`
  text-transform: uppercase;
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
  { path: '/topic/technology', topic: 'Technology' },
  { path: '/topic/culture', topic: 'Culture' },
  { path: '/topic/technology', topic: 'Technology2' },
  { path: '/topic/culture', topic: 'Culture2' },
  { path: '/topic/technology', topic: 'Technology3' },
  { path: '/topic/culture', topic: 'Culture3' },
  { path: '/topic/technology', topic: 'Technology4' },
  { path: '/topic/culture', topic: 'Culture4' },
  { path: '/topic/technology', topic: 'Technology5' },
  { path: '/topic/culture', topic: 'Culture5' },
  { path: '/topic/technology', topic: 'Technology6' },
  { path: '/topic/culture', topic: 'Culture6' },
];

const activeClassName = 'nav-link-active';
const StyledLink = styled(NavLink).attrs({ activeClassName })`
  font-size: 0.82rem;

  text-decoration: none;

  &.${activeClassName} {
    color: red;
  }
`;

const renderTopics = (topicList, addTopicElem) =>
  topicList.map(({ path, topic }) => (
    <StyledItem ref={addTopicElem} key={topic}>
      <StyledLink to={path}>{topic}</StyledLink>
    </StyledItem>
  ));

export default class TopicBar extends Component {
  state = { bottomShadow: false };

  componentDidMount() {
    this.visibleTopicRange = [0, 0];

    const topicIntersectionObserverOptions = {
      root: this.topicListElem,
      threshold: 1,
    };

    this.topicIntersectionObserver = new IntersectionObserver(
      this.handleTopicVisibilityChange,
      topicIntersectionObserverOptions,
    );

    // Observe every topic element.
    this.topicElems.map(topicElem => this.topicIntersectionObserver.observe(topicElem));
  }

  componentWillUnmount() {
    this.topicIntersectionObserver.disconnect();
  }

  /**
   * This Intersection Observer will the visibility of every
   * topic element.
   */

  topicElems = [];
  topicIntersectionObserver = null;
  visibleTopicRange = null;
  topicListElem = null;
  topicListWrapperElem = null;

  addTopicElem = (elem) => {
    this.topicElems = [...this.topicElems, elem];
  };

  handleTopicVisibilityChange = entries => entries;

  addTopicListElem = (elem) => {
    this.topicListElem = elem;
  };

  addTopicListWrapperElem = (elem) => {
    this.topicListWrapperElem = elem;
  };

  /**
   * Callback that is called when the sentinel
   * (the element the IntersectionObserver is observing)
   * changes its intersection state with respect to the viewport.
   */
  handleBarIntersectionChange = ({ isIntersecting }) =>
    this.setState({ bottomShadow: !isIntersecting });

  handleLeftNavControlClick = () => {
    this.listWrapperElem.scrollLeft = 0;
  };

  handleRightNavControlClick = () => {
    this.listWrapperElem.scrollLeft = this.listElem.scrollWidth;
  };

  render() {
    return (
      <Fragment>
        <Observer onChange={this.handleBarIntersectionChange}>
          <Sentinel />
        </Observer>
        <StyledNav bottomShadow={this.state.bottomShadow}>
          <NavWrapper>
            <NavControl onClick={this.handleLeftNavControlClick} left>
              &lt;
            </NavControl>
            <TopicListWrapper innerRef={this.addTopicListWrapperElem}>
              <TopicList innerRef={this.addTopicListElem}>
                {renderTopics(topics, this.addTopicElem)}
              </TopicList>
            </TopicListWrapper>
            <NavControl onClick={this.handleRightNavControlClick} right>
              &gt;
            </NavControl>
          </NavWrapper>
        </StyledNav>
      </Fragment>
    );
  }
}
