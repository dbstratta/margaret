import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import ContentLoader from 'react-content-loader';
import styled from 'styled-components';

const Article = styled.article`
  display: flex;

  flex-flow: column nowrap;
  justify-content: flex-end;
`;

const Story = styled.div`
  flex: 1 1 auto;

  @media (min-width: ${props => props.theme.breakpoints.md}) {
    margin-top: var(--sm-space);

    order: 1;
  }
`;

const Title = styled.h3`
  font-size: var(--ml-font-size);

  margin: 0 0 var(--xs-space);
`;

const Meta = styled.div`
  font-size: var(--xs-font-size);
  color: var(--secondary-font-color);

  padding-bottom: var(--xs-space);
`;

const Image = styled(Link)`
  flex: 0 0 50%;

  min-height: 6.4rem;
  max-height: 9rem;

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
    const Placeholder = styled.div`
      flex: 0 0 50%;
      min-height: 6.4rem;
      max-height: 9rem;
    `;

    return <Placeholder />;
  }
  return <Image to="/" src="https://picsum.photos/600/601" />;
};

const FeaturedMedium = ({ story, loading, className }) => (
  <Article className={className}>
    <Story>
      {renderTitle(story, loading)}
      {renderMeta(story, loading)}
    </Story>
    {renderImage(story, loading)}
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
