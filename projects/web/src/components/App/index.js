import React from 'react';
import { Switch, Route } from 'react-router-dom';

import Index from '../../pages/Index';
import NewStory from '../../pages/NewStory';
import Story from '../../pages/Story';
import Profile from '../../pages/Profile';
import Publication from '../../pages/Publication';

export const App = () => (
  <Switch>
    <Route exact path="/" component={Index} />
    <Route path="/new" component={NewStory} />
    <Route exact path="/@:username" component={Profile} />
    <Route path="/@:author/:slug" component={Story} />
    <Route exact path="/:publication" component={Publication} />
    <Route path="/:publication/:slug" component={Story} />
  </Switch>
);

export default App;
