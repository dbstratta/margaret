import { createStore, applyMiddleware } from 'redux';
import createSagaMiddleware from 'redux-saga';
import { composeWithDevTools } from 'remote-redux-devtools';
import createImmutableStateInvariantMiddleware from 'redux-immutable-state-invariant';

import rootReducer from '../rootReducer';

const sagaMiddleware = createSagaMiddleware();
const immutableStateInvariantMiddleware = createImmutableStateInvariantMiddleware();

const composeEnhancers = composeWithDevTools;

export default (initialState) => {
  const store = createStore(
    rootReducer,
    initialState,
    composeEnhancers(applyMiddleware(sagaMiddleware, immutableStateInvariantMiddleware)),
  );

  if (module.hot) {
    // Enable hot module replacement for reducers.
    module.hot.accept('../rootReducer', () => store.replaceReducer(rootReducer));
  }

  return { ...store, runSaga: sagaMiddleware.run };
};
