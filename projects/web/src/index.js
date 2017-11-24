import 'rxjs';

import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import createHistory from 'history/createBrowserHistory';

import './globalStyles';

import Root from './components/Root';
import registerServiceWorker from './registerServiceWorker';
import configureApollo from './configureApollo';
import configureStore from './store';

const history = createHistory();

const client = configureApollo();
const store = configureStore({ history });

const render = (RootComponent) => {
  const tree = (
    <AppContainer>
      <RootComponent client={client} store={store} history={history} />
    </AppContainer>
  );

  ReactDOM.render(tree, document.getElementById('root'));
};

render(Root);

if (module.hot) {
  module.hot.accept('./components/Root', () => render(Root));
}

registerServiceWorker();
