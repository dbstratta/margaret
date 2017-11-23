import { createStore, applyMiddleware } from 'redux';
import { createEpicMiddleware } from 'redux-observable';
import { routerMiddleware as createRouterMiddleware } from 'react-router-redux';

import rootReducer from '../rootReducer';
import rootEpic from '../rootEpic';

export default function configureStore({ initialState, history }) {
  const epicMiddlware = createEpicMiddleware(rootEpic);
  const routerMiddleware = createRouterMiddleware(history);

  const middleware = applyMiddleware(epicMiddlware, routerMiddleware);

  return createStore(rootReducer, initialState, middleware);
}
