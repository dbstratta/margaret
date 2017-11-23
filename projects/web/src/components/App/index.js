import React from 'react';
import { Switch, Route } from 'react-router-dom';

import Index from '../../pages/Index';
import Story from '../../pages/Story';

const App = () => (
  <Switch>
    <Route exact path="/" component={Index} />
    <Route exact path="/:author/:slug" component={Story} />
  </Switch>
);

export default App;
