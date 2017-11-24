import { createStore, applyMiddleware } from 'redux';
import { createEpicMiddleware } from 'redux-observable';
import { routerMiddleware as createRouterMiddleware } from 'react-router-redux';

import rootReducer from '../rootReducer';
import rootEpic from '../rootEpic';

export default ({ initialState, history }) =>
  createStore(
    rootReducer,
    initialState,
    applyMiddleware(createEpicMiddleware(rootEpic), createRouterMiddleware(history)),
  );
