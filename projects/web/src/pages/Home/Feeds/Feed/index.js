import React from 'react';
import PropTypes from 'prop-types';
import { Query } from 'react-apollo';
import gql from 'graphql-tag';

const Feed = ({ stories, loading }) => <div>feed</div>;

Feed.propTypes = {
  stories: PropTypes.array.isRequired,
  loading: PropTypes.bool.isRequired,
};

const feedQuery = gql`
  query Feed {
    feed(first: 5) {
      edges {
        node {
          title
          summary
          author {
            firstName
            lastName
            username
          }
          publication {
            displayName
            name
          }
          slug
          readTime
          isUnderPublication
        }
      }
    }
  }
`;

const getStories = data => (data ? data.feed.edges.map(edge => edge.node) : []);

const FeedEnhancer = props => (
  <Query query={feedQuery}>
    {({ data, loading, error }) => {
      if (error) {
        return 'error';
      }

      const stories = getStories(data);

      return <Feed stories={stories} loading={loading} {...props} />;
    }}
  </Query>
);

export default FeedEnhancer;
