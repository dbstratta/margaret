import React from 'react';
import { Switch, Route } from 'react-router-dom';

import Index from '../../pages/Index';

const App = () => (
  <Switch>
    <Route exact path="/" component={Index} />
  </Switch>
);

export default App;
