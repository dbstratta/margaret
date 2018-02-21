import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import ContentLoader from 'react-content-loader';
import styled from 'styled-components';

const StoryList = styled.div`
  border-top: 0.13rem solid var(--primary-font-color);
`;

const Article = styled.article`
  padding: calc(var(--xs-space) * (1 + 1 / 3)) 0;
`;

const Title = styled.h3`
  font-size: calc(var(--sm-font-size) * (1 + 1 / 8));

  margin: 0;
`;

const Meta = styled.div`
  font-size: var(--xs-font-size);
  color: var(--secondary-font-color);
`;

const Separator = styled.div`
  width: 27%;

  border-top: 0.07rem solid var(--tertiary-font-color);
`;

const renderTitle = (story, loading) => {
  const loader = (
    <ContentLoader width={400} height={15}>
      <rect x="0" y="0" rx="5" ry="5" width="80%" height="100%" />
    </ContentLoader>
  );

  return <Title>{loading ? loader : story.title}</Title>;
};

const renderMeta = (story, loading) => {
  const loader = (
    <ContentLoader width={400} height={10}>
      <rect x="0" y="0" rx="5" ry="5" width="30%" height="100%" />
    </ContentLoader>
  );

  if (loading) {
    return <Meta>{loader}</Meta>;
  }

  const { author, publication } = story;

  const authorName = publication
    ? publication.displayName
    : `${author.firstName} ${author.lastName}`;

  return <Meta>{authorName}</Meta>;
};

const renderStories = (stories, loading) => {
  const storyList = loading ? Array.from({ length: 3 }) : stories;

  return storyList.map((story, index) => (
    <Fragment key={loading ? index : story.id}>
      <Article>
        {renderTitle(story, loading)}
        {renderMeta(story, loading)}
      </Article>
      <Separator />
    </Fragment>
  ));
};

const FeaturedCompact = ({ stories, loading, className }) => (
  <StoryList className={className}>{renderStories(stories, loading)}</StoryList>
);

FeaturedCompact.propTypes = {
  stories: PropTypes.arrayOf(PropTypes.object),
  loading: PropTypes.bool.isRequired,
  className: PropTypes.string,
};

FeaturedCompact.defaultProps = {
  stories: [],
  className: '',
};

export default FeaturedCompact;
