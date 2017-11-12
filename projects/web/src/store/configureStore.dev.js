import { createStore, applyMiddleware } from 'redux';
import createSagaMiddleware, { END } from 'redux-saga';
import { composeWithDevTools } from 'redux-devtools-extension';
import createImmutableStateInvariantMiddleware from 'redux-immutable-state-invariant';

import rootReducer from '../rootReducer';
import rootSaga from '../rootSaga';

const sagaMiddleware = createSagaMiddleware();
const immutableStateInvariantMiddleware = createImmutableStateInvariantMiddleware();

const composeEnhancers = composeWithDevTools;

export default function configureStore(initialState) {
  const store = createStore(
    rootReducer,
    initialState,
    composeEnhancers(applyMiddleware(sagaMiddleware, immutableStateInvariantMiddleware)),
  );

  if (module.hot) {
    // Enable hot module replacement for reducers.
    module.hot.accept('../rootReducer', () => store.replaceReducer(rootReducer));
  }

  store.sagaTask = sagaMiddleware.run(rootSaga);
  store.close = () => store.dispatch(END);

  return store;
}
