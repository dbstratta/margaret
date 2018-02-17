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

const renderTopics = (topicList, { addElement, handleChange, rootElement }) =>
  topicList.map(({ path, topic }, index) => (
    <Observer
      onChange={handleChange(index)}
      threshold={1}
      key={topic}
      disabled={!rootElement}
      root={rootElement}
    >
      <StyledItem ref={addElement}>
        {console.log(rootElement)}
        <StyledLink to={path}>{topic}</StyledLink>
      </StyledItem>
    </Observer>
  ));

export default class TopicBar extends Component {
  state = {
    bottomShadow: false,
    leftNavControlDisabled: true,
    rightNavControlDisabled: false,
    topicListWrapperElement: null,
  };

  visibleTopicRange = [0, 0];

  addTopicElem = (elem) => {
    const elements = this.topicElements || [];

    this.topicElements = [...elements, elem];
  };

  setVisibleTopicRange = (first, last) => {
    this.visibleTopicRange = [first, last];

    if (first === 0) {
      this.setState({ leftNavControlDisabled: true });
    }
  };

  handleTopicVisibilityChange = index => (event) => {};

  /**
   * We store the node
   */
  addTopicListElement = (el) => {
    this.topicListElement = el;
  };

  addTopicListWrapperElement = el => this.setState({ topicListWrapperElement: el });

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
            <NavControl
              left
              onClick={this.handleLeftNavControlClick}
              disabled={this.state.leftNavControlDisabled}
            >
              &lt;
            </NavControl>
            <TopicListWrapper innerRef={this.addTopicListWrapperElement}>
              <TopicList innerRef={this.addTopicListElement}>
                {renderTopics(topics, {
                  addElement: this.addTopicElem,
                  handleChange: this.handleTopicVisibilityChange,
                  rootElement: this.state.topicListWrapperElement,
                })}
              </TopicList>
            </TopicListWrapper>
            <NavControl
              right
              onClick={this.handleRightNavControlClick}
              disabled={this.state.rightNavControlDisabled}
            >
              &gt;
            </NavControl>
          </NavWrapper>
        </StyledNav>
      </Fragment>
    );
  }
}
