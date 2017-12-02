import React, { Fragment } from 'react';

import TopBar from '../../components/TopBar';
import TopicBar from './TopicBar';
import { withAuth } from '../../hocs';

const Index = () => (
  <Fragment>
    <TopBar />
    <TopicBar />
  </Fragment>
);

const enhance = withAuth;

export default enhance(Index);
