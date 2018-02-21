import React, { Fragment } from 'react';
import styled from 'styled-components';

import TopBar from '../../components/TopBar';
import TopicBar from './TopicBar';
import HeroGrid from './HeroGrid';
import Feeds from './Feeds';

const StyledHeroGrid = styled(HeroGrid)`
  margin-top: var(--sm-space);
`;

const Home = () => (
  <Fragment>
    <TopBar pinnable={false} />
    <TopicBar />
    <StyledHeroGrid />
    <Feeds />
  </Fragment>
);

export default Home;
