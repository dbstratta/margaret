import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import ContentLoader from 'react-content-loader';
import styled from 'styled-components';

import { truncateString } from '../../../../utils';

const getAlignArticleProp = (story, loading) => {
  if (loading || !story.image) {
    return 'stretch';
  }
  return 'center';
};

const Article = styled.article`
  --grid-template-columns: [image-start story-start] 1fr [image-end story-end];
  --grid-template-rows: [heading-start] auto [headint-end] auto [image-start] 1fr [image-end];
  --grid-gap: var(--xs-space);

  display: grid;

  grid-template-columns: var(--grid-template-columns);
  grid-template-rows: var(--grid-template-rows);
  grid-row-gap: var(--grid-gap);
  justify-items: stretch;
  align-items: stretch;

  align-self: ${({ story, loading }) => getAlignArticleProp(story, loading)};

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    --grid-template-columns: [image-start] 3fr [story-start] 17fr [image-end story-end];
  }
`;

const Heading = styled.div`
  grid-column: story;
  justify-self: start;

  padding-top: var(--xs-space);

  border-top: 0.13rem solid var(--primary-font-color);

  color: var(--primary-font-color);
  text-transform: uppercase;
  font-size: var(--xs-font-size);
`;

const Story = styled.div`
  --padding: 0;

  grid-column: story;

  padding: var(--padding);

  @media (min-width: ${props => props.theme.breakpoints.xl}) {
    --padding: var(--xs-space) 0 var(--sm-space);
  }
`;

const Title = styled.h3`
  font-size: var(--lg-font-size);

  margin: 0 0 var(--xs-space);
`;

const Summary = styled.p`
  color: var(--secondary-font-color);

  margin: 0 0 var(--sm-space);
`;

const Meta = styled.div`
  font-size: var(--xs-font-size);
  color: var(--secondary-font-color);
`;

const Image = styled(Link)`
  grid-column: image;
  grid-row: image;

  min-height: 6rem;

  background-image: url(${props => props.src});
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
`;

const renderTitle = (story, loading) => {
  const loader = (
    <ContentLoader width={400} height={15}>
      <rect x="0" y="0" rx="5" ry="5" width="80%" height="100%" />
    </ContentLoader>
  );

  return <Title>{loading ? loader : truncateString(story.title, 100)}</Title>;
};

const renderSummary = (story, loading) => {
  const loader = (
    <ContentLoader width={400} height={12}>
      <rect x="0" y="0" rx="5" ry="5" width="100%" height="100%" />
    </ContentLoader>
  );

  return <Summary>{loading ? loader : truncateString(story.summary, 100)}</Summary>;
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

  const { author, publication, readTime } = story;

  const authorName = publication
    ? publication.displayName
    : `${author.firstName} ${author.lastName}`;

  return (
    <Meta>
      {authorName} · {readTime} min read
    </Meta>
  );
};

const renderImage = (story, loading) => {
  if (loading) {
    return null;
  }

  const authorSlug = story.isUnderPublication
    ? story.publication.name
    : `@${story.author.username}`;

  return <Image to={`/${authorSlug}/${story.slug}`} src="https://picsum.photos/700/900" />;
};

const FeaturedLarge = ({ story, loading, className }) => (
  <Article story={story} loading={loading} className={className}>
    <Heading>Featured</Heading>
    <Story>
      {renderTitle(story, loading)}
      {renderSummary(story, loading)}
      {renderMeta(story, loading)}
    </Story>
    {renderImage(story, loading)}
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
