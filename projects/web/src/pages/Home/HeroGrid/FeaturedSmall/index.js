import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import ContentLoader from 'react-content-loader';
import styled from 'styled-components';

import { truncateString } from '../../../../utils';

const Article = styled.article`
  --padding-bottom: 0;

  display: flex;

  flex-flow: column nowrap;
  justify-content: flex-end;

  padding-bottom: var(--padding-bottom);

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    --padding-bottom: var(--xs-space);
  }
`;

const Story = styled.div`
  flex: 1 1 auto;

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    margin-top: var(--xs-space);

    order: 1;
  }
`;

const Title = styled.h3`
  font-size: calc(var(--md-font-size) * 1.05);

  margin: 0 0 calc(var(--xs-space) / 3);
`;

const Summary = styled.div`
  font-size: var(--sm-font-size);
  color: var(--secondary-font-color);

  margin: 0 0 calc(var(--xs-space) * 2 / 3);
`;

const Meta = styled.div`
  font-size: var(--xs-font-size);
  color: var(--secondary-font-color);

  padding-bottom: var(--xs-space);
`;

const Image = styled(Link)`
  flex: 0 0 auto;

  height: 6.4rem;

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

  return <Title>{loading ? loader : truncateString(story.title, 50)}</Title>;
};

const renderSummary = (story, loading) => {
  const loader = (
    <ContentLoader width={400} height={12}>
      <rect x="0" y="0" rx="5" ry="5" width="100%" height="100%" />
    </ContentLoader>
  );

  return <Summary>{loading ? loader : truncateString(story.summary, 60)}</Summary>;
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

const renderImage = (story, loading) => {
  if (loading) {
    const Placeholder = styled.div`
      flex: 0 0 auto;
      height: 6rem;
    `;

    return <Placeholder />;
  }
  return <Image to="/" src={`https://picsum.photos/500/${Math.random() * 200 + 500}`} />;
};

const FeaturedSmall = ({ story, loading, className }) => (
  <Article className={className}>
    <Story>
      {renderTitle(story, loading)}
      {renderSummary(story, loading)}
      {renderMeta(story, loading)}
    </Story>
    {renderImage(story, loading)}
  </Article>
);

FeaturedSmall.propTypes = {
  story: PropTypes.object,
  loading: PropTypes.bool.isRequired,
  className: PropTypes.string,
};

FeaturedSmall.defaultProps = {
  story: null,
  className: '',
};

export default FeaturedSmall;
