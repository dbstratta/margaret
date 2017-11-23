import { createStore, applyMiddleware } from 'redux';
import { createEpicMiddleware } from 'redux-observable';
import { routerMiddleware as createRouterMiddleware } from 'react-router-redux';
import { composeWithDevTools } from 'redux-devtools-extension';
import loggerMiddleware from 'redux-logger';
import createImmutableStateInvariantMiddleware from 'redux-immutable-state-invariant';

import rootReducer from '../rootReducer';
import rootEpic from '../rootEpic';

export default function configureStore({ initialState, history }) {
  const epicMiddlware = createEpicMiddleware(rootEpic);
  const routerMiddleware = createRouterMiddleware(history);
  const immutableStateInvariantMiddleware = createImmutableStateInvariantMiddleware();

  const middleware = applyMiddleware(
    epicMiddlware,
    routerMiddleware,
    loggerMiddleware,
    immutableStateInvariantMiddleware,
  );

  const store = createStore(rootReducer, initialState, composeWithDevTools(middleware));

  if (module.hot) {
    module.hot.accept('../rootReducer', () => store.replaceReducer(rootReducer));
    module.hot.accept('../rootEpic', () => epicMiddlware.replaceEpic(rootEpic));
  }

  return store;
}
