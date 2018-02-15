/**
 * HeroGrid is the hero grid with featured stories
 * on the homepage.
 */

import React from 'react';
import { graphql } from 'react-apollo';
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

const HeroGrid = () => (
  <Grid>
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

const withData = graphql(featuredFeedQuery);

const enhance = withData;

export default enhance(HeroGrid);
