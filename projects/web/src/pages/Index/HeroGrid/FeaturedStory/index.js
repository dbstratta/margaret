import React from 'react';
import PropTypes from 'prop-types';
import styled from 'styled-components';

const FeaturedStory = ({ story, loading }) => <div>Featured story</div>;

FeaturedStory.propTypes = {
  story: PropTypes.object,
  loading: PropTypes.bool.isRequired,
};

FeaturedStory.defaultProps = {
  story: null,
};

export default FeaturedStory;
