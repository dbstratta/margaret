import React from 'react';
import PropTypes from 'prop-types';
import styled from 'styled-components';

const Article = styled.article`
  --grid-template-columns: [image-start story-start] 1fr [image-end story-end];
  --grid-template-rows: auto 1fr 1fr;
  --grid-gap: var(--xs-space);

  display: grid;

  grid-template-columns: var(--grid-template-columns);
  grid-template-rows: var(--grid-template-rows);

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    --grid-template-columns: [image-start] 1fr [story-start] 5fr [image-end story-end];
  }
`;

const Story = styled.div`
  grid-column: story;
`;

const Title = styled.h3``;

const renderTitle = (story, loading) => {
  if (loading) {
    return 'loading...';
  }

  return <Title>{story.title}</Title>;
};

const FeaturedLarge = ({ story, loading, className }) => (
  <Article className={className}>
    <Story>
      {renderTitle(story, loading)}
      Description
    </Story>
  </Article>
);

FeaturedLarge.propTypes = {
  story: PropTypes.object,
  loading: PropTypes.bool.isRequired,
  className: PropTypes.string,
};

FeaturedLarge.defaultProps = {
  story: null,
  className: '',
};

export default FeaturedLarge;
