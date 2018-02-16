import React, { Fragment } from 'react';

import TopBar from '../../components/TopBar';
import TopicBar from './TopicBar';
import HeroGrid from './HeroGrid';

const Index = () => (
  <Fragment>
    <TopBar pinnable={false} />
    <TopicBar />
    <HeroGrid />
  </Fragment>
);

export default Index;
