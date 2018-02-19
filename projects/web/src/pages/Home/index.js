import React, { Fragment } from 'react';
import styled from 'styled-components';

import TopBar from '../../components/TopBar';
import TopicBar from './TopicBar';
import HeroGrid from './HeroGrid';

const StyledHeroGrid = styled(HeroGrid)`
  margin-top: var(--sm-space);
`;

const Home = () => (
  <Fragment>
    <TopBar pinnable={false} />
    <TopicBar />
    <StyledHeroGrid />
  </Fragment>
);

export default Home;
