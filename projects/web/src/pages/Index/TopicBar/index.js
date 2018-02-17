/**
 * The TopicBar is the bar displayed below the main bar
 * and has a list of links to story topics.
 */

import React, { Component, Fragment } from 'react';
import { findDOMNode } from 'react-dom';
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
  border: none;

  margin-right: ${({ left }) => (left ? 'var(--sm-space)' : 0)};
  margin-left: ${({ right }) => (right ? 'var(--sm-space)' : 0)};
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
const StickySentinel = styled.div`
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

const renderTopics = (topicList, { addElement, handleChange }) =>
  topicList.map(({ path, topic }, index) => (
    <Observer onChange={handleChange(index)} threshold={1} key={topic}>
      <StyledItem ref={addElement}>
        <StyledLink to={path}>{topic}</StyledLink>
      </StyledItem>
    </Observer>
  ));

export default class TopicBar extends Component {
  state = {
    bottomShadow: false,
    visibleTopicRange: [0, 0],
  };

  /**
   * We store the topic React elements to be able
   * to scrollIntoView() them among other things.
   */
  topicElements = [];

  addTopicElem = (elem) => {
    this.topicElements = [...this.topicElements, elem];
  };

  /**
   * Handler for the topics Intersection Observer.
   * It updates the visible range of topics.
   */
  handleTopicVisibilityChange = index => (event) => {
    // A topic element is leaving the visible range.
    if (event.intersectionRatio < 1) {
      if (index === this.state.visibleTopicRange[0]) {
        this.setState(({ visibleTopicRange }) => ({
          visibleTopicRange: [index + 1, visibleTopicRange[1]],
        }));
      } else if (index <= this.state.visibleTopicRange[1]) {
        this.setState(({ visibleTopicRange }) => ({
          visibleTopicRange: [visibleTopicRange[0], index - 1],
        }));
      }
      // A topic element is entering the visible range.
    } else {
      // eslint-disable-next-line no-lonely-if
      if (index < this.state.visibleTopicRange[0]) {
        this.setState(({ visibleTopicRange }) => ({
          visibleTopicRange: [index, visibleTopicRange[1]],
        }));
      } else if (index > this.state.visibleTopicRange[1]) {
        this.setState(({ visibleTopicRange }) => ({
          visibleTopicRange: [visibleTopicRange[0], index],
        }));
      }
    }
  };

  addTopicListElement = (el) => {
    this.topicListElement = el;
  };

  handleStickySentinelVisibilityChange = ({ isIntersecting }) =>
    this.setState({ bottomShadow: !isIntersecting });

  canScrollLeft = () => this.state.visibleTopicRange[0] > 0;

  canScrollRight = () => this.state.visibleTopicRange[1] < this.topicElements.length - 1;

  handleLeftNavControlClick = () => {
    if (this.canScrollLeft()) {
      const elementToScrollTo = this.topicElements[this.state.visibleTopicRange[0] - 1];

      // We need the native DOM node to use scrollIntoView.
      // eslint-disable-next-line react/no-find-dom-node
      findDOMNode(elementToScrollTo).scrollIntoView({ block: 'nearest', inline: 'end' });
    }
  };

  handleRightNavControlClick = () => {
    if (this.canScrollRight()) {
      const elementToScrollTo = this.topicElements[this.state.visibleTopicRange[1] + 1];

      // We need the native DOM node to use scrollIntoView.
      // eslint-disable-next-line react/no-find-dom-node
      findDOMNode(elementToScrollTo).scrollIntoView({ block: 'nearest', inline: 'start' });
    }
  };

  render() {
    return (
      <Fragment>
        <Observer onChange={this.handleStickySentinelVisibilityChange}>
          <StickySentinel />
        </Observer>
        <StyledNav bottomShadow={this.state.bottomShadow}>
          <NavWrapper>
            <NavControl
              left
              onClick={this.handleLeftNavControlClick}
              disabled={!this.canScrollLeft()}
            >
              &lt;
            </NavControl>
            <TopicListWrapper innerRef={this.addTopicListWrapperElement}>
              <TopicList innerRef={this.addTopicListElement}>
                {renderTopics(topics, {
                  addElement: this.addTopicElem,
                  handleChange: this.handleTopicVisibilityChange,
                })}
              </TopicList>
            </TopicListWrapper>
            <NavControl
              right
              onClick={this.handleRightNavControlClick}
              disabled={!this.canScrollRight()}
            >
              &gt;
            </NavControl>
          </NavWrapper>
        </StyledNav>
      </Fragment>
    );
  }
}
