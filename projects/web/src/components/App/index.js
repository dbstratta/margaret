import React from 'react';
import { Switch, Route } from 'react-router-dom';

import Index from '../../pages/Index';
import NewStory from '../../pages/NewStory';
import Story from '../../pages/Story';
import Stats from '../../pages/Stats';
import Series from '../../pages/Series';
import Profile from '../../pages/Profile';
import Publication from '../../pages/Publication';

export const App = () => (
  <Switch>
    <Route exact path="/" component={Index} />
    <Route path="/new" component={NewStory} />
    <Route path="/stats" component={Stats} />
    <Route path="/series/:series" component={Series} />
    <Route path="/topic/:topic" component={Story} />
    <Route exact path="/@:username" component={Profile} />
    <Route exact path="/:publication" component={Publication} />
    <Route path="/:author/:slug" component={Story} />
  </Switch>
);

export default App;
