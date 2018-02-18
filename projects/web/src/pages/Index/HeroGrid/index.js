/**
 * HeroGrid is the hero grid with featured stories
 * on the homepage.
 */

import React from 'react';
import PropTypes from 'prop-types';
import { Query } from 'react-apollo';
import gql from 'graphql-tag';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

import FeaturedLarge from './FeaturedLarge';
import FeaturedMedium from './FeaturedMedium';
import FeaturedSmall from './FeaturedSmall';
import FeaturedExtraSmall from './FeaturedExtraSmall';

const Grid = styled.section`
  --width: var(--main-content-width);

  --grid-gap: var(--xs-space);
  --grid-template-columns: 1fr;
  --grid-template-rows: none;

  display: grid;
  grid-gap: var(--grid-gap);
  grid-template-columns: var(--grid-template-columns);
  grid-template-rows: var(--grid-template-rows);
  grid-template-areas: none;

  width: var(--width);

  margin: auto;

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    --grid-template-columns: [grid-left] 2fr 1fr [grid-right];
    --grid-template-rows: [grid-top] repeat(3, 1fr) auto [grid-bottom];
    grid-template-areas:
      'lg  md  '
      'lg  sm1 '
      'lg  sm2 '
      'lg  more';
  }

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    --grid-template-columns: [grid-left] 5fr repeat(3, 2fr) [grid-right];
    --grid-template-rows: [grid-top] 2fr repeat(3, 1fr) auto [grid-bottom];
    grid-template-areas:
      'lg  sm1   sm2  sm3'
      'lg  sm1   sm2  sm3'
      'lg  xs1   md   md '
      'lg  xs2   md   md '
      'lg  xs3   md   md '
      'lg  more  md   md ';

    --width: calc(var(--main-content-width) + (100% - var(--main-content-width)) * 7 / 8);
  }
`;

const StyledFeaturedLarge = styled(FeaturedLarge)`
  @media (min-width: ${props => props.theme.breakpoints.md}) {
    grid-area: lg;
  }
`;

const StyledFeaturedMedium = styled(FeaturedMedium)`
  @media (min-width: ${props => props.theme.breakpoints.md}) {
    grid-area: md;
  }
`;

const StyledFeaturedSmall = styled(FeaturedSmall)`
  @media (min-width: ${props => props.theme.breakpoints.md}) {
    grid-area: sm${props => props.pos};
  }

  @media (max-width: ${props => props.theme.breakpoints.xl}) {
    ${props => props.pos === 3 && 'display: none;'};
  }
`;

const StyledFeaturedExtraSmall = styled(FeaturedExtraSmall)`
  --display: none;

  display: var(--display);

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    grid-area: xs${props => props.pos};
  }

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    --display: initial;
  }
`;

const AllFeaturedLink = styled(Link)`
  @media (min-width: ${props => props.theme.breakpoints.md}) {
    grid-area: more;
  }
`;

const HeroGrid = ({ stories, loading }) => (
  <Grid>
    <StyledFeaturedLarge story={stories[0]} loading={loading} />
    <StyledFeaturedMedium story={stories[1]} loading={loading} />
    <StyledFeaturedSmall pos={1} story={stories[2]} loading={loading} />
    <StyledFeaturedSmall pos={2} story={stories[3]} loading={loading} />
    <StyledFeaturedSmall pos={3} story={stories[4]} loading={loading} />
    <StyledFeaturedExtraSmall pos={1} story={stories[5]} loading={loading} />
    <StyledFeaturedExtraSmall pos={2} story={stories[6]} loading={loading} />
    <StyledFeaturedExtraSmall pos={3} story={stories[7]} loading={loading} />
    <AllFeaturedLink to="/">See all featured</AllFeaturedLink>
  </Grid>
);

const storyPropType = PropTypes.shape({
  title: PropTypes.string.isRequired,
  author: PropTypes.shape({
    firstName: PropTypes.string,
    lastName: PropTypes.string,
  }).isRequired,
  publication: PropTypes.shape({
    displayName: PropTypes.string.isRequired,
  }),
});

HeroGrid.propTypes = {
  stories: PropTypes.arrayOf(storyPropType).isRequired,
  loading: PropTypes.bool.isRequired,
};

const featuredFeedQuery = gql`
  query FeaturedFeed {
    feed(first: 8) {
      edges {
        node {
          title
          author {
            firstName
            lastName
          }
          publication {
            displayName
          }
        }
      }
    }
  }
`;

const getStories = data => (data ? data.feed.edges.map(edge => edge.node) : []);

const EnhancedHeroGrid = () => (
  <Query query={featuredFeedQuery}>
    {({ data, loading, error }) => {
      if (error) {
        return 'error';
      }

      const stories = getStories(data);

      return <HeroGrid stories={stories} loading={loading} />;
    }}
  </Query>
);

export default EnhancedHeroGrid;
