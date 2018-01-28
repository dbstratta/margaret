import React from 'react';
import { Switch, Route } from 'react-router-dom';

import Index from '../../pages/Index';
import EditStory from '../../pages/EditStory';
import Story from '../../pages/Story';
import Profile from '../../pages/Profile';
import Publication from '../../pages/Publication';

export const App = () => (
  <Switch>
    <Route exact path="/" component={Index} />
    <Route path="/p/:storyHash" component={EditStory} />
    <Route path="/topic/:topic" component={Story} />
    <Route exact path="/@:username" component={Profile} />
    <Route exact path="/:publication" component={Publication} />
    <Route path="/:name/:slug" component={Story} />
  </Switch>
);

export default App;
