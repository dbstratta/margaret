import React from 'react';
import PropTypes from 'prop-types';
import styled from 'styled-components';

const Article = styled.article`
  display: grid;
`;

const renderTitle = (story, loading) => {
  if (loading) {
    return 'loading...';
  }

  return <h3>{story.title}</h3>;
};

const FeaturedMedium = ({ story, loading, className }) => (
  <Article className={className}>
    {renderTitle(story, loading)}
    Description
  </Article>
);

FeaturedMedium.propTypes = {
  story: PropTypes.object,
  loading: PropTypes.bool.isRequired,
  className: PropTypes.string,
};

FeaturedMedium.defaultProps = {
  story: null,
  className: '',
};

export default FeaturedMedium;
