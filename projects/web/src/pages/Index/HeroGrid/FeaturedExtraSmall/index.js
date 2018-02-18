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

const FeaturedExtraSmall = ({ story, loading, className }) => (
  <Article className={className}>
    {renderTitle(story, loading)}
    Description
  </Article>
);

FeaturedExtraSmall.propTypes = {
  story: PropTypes.object,
  loading: PropTypes.bool.isRequired,
  className: PropTypes.string,
};

FeaturedExtraSmall.defaultProps = {
  story: null,
  className: '',
};

export default FeaturedExtraSmall;
