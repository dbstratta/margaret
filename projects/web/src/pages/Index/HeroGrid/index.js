/**
 * HeroGrid is the hero grid with featured stories
 * on the homepage.
 */

import React from 'react';
import PropTypes from 'prop-types';
import { Query } from 'react-apollo';
import gql from 'graphql-tag';
import styled from 'styled-components';

const Grid = styled.section`
  --grid-gap: ${props => props.theme.spacing.sizes.xs};

  display: grid;
  grid-gap: var(--grid-gap);
  grid-template-columns: [grid-left] 3fr repeat(3, 1fr) [grid-right];
  grid-template-rows: [grid-top] auto 2fr repeat(3, 1fr) auto [grid-bottom];
  grid-template-areas:
    'title  title  title  title'
    'lg     lg     lg     lg   '
    'lg     lg     lg     lg   '
    'md     md     md     md   '
    'md     md     md     md   '
    'more   more   more   more ';

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    grid-template-areas:
      'title  sm1   sm2  sm3'
      'lg     sm1   sm2  sm3'
      'lg     xs1   md   md '
      'lg     xs2   md   md '
      'lg     xs3   md   md '
      'lg     more  md   md ';
  }

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    grid-template-areas:
      'title  sm1   sm2  sm3'
      'lg     sm1   sm2  sm3'
      'lg     xs1   md   md '
      'lg     xs2   md   md '
      'lg     xs3   md   md '
      'lg     more  md   md ';
  }
`;

const HeroGrid = ({ feed, loading }) => (
  <Grid>
    LOADING: {`${loading}`}
    FEED: {JSON.stringify(feed)}
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
    LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM LOREM IPSUM
  </Grid>
);

const nodePropType = PropTypes.shape({
  title: PropTypes.string.isRequired,
  author: PropTypes.shape({
    firstName: PropTypes.string,
    lastName: PropTypes.string,
  }).isRequired,
  publication: PropTypes.shape({
    displayName: PropTypes.string.isRequired,
  }),
});

const edgePropType = PropTypes.arrayOf(nodePropType);
const feedPropType = PropTypes.objectOf(edgePropType);

HeroGrid.propTypes = {
  feed: feedPropType,
  loading: PropTypes.bool.isRequired,
};

HeroGrid.defaultProps = {
  feed: null,
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

const EnhancedHeroGrid = () => (
  <Query query={featuredFeedQuery}>
    {({ data, loading, error }) => {
      if (error) {
        return 'error';
      }

      return <HeroGrid feed={data.feed} loading={loading} />;
    }}
  </Query>
);

export default HeroGrid;
