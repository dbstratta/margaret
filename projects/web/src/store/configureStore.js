import { createStore, applyMiddleware } from 'redux';
import createSagaMiddleware, { END } from 'redux-saga';

import rootReducer from '../rootReducer';
import rootSaga from '../rootSaga';

const sagaMiddleware = createSagaMiddleware();

export default (initialState) => {
  const store = createStore(rootReducer, initialState, applyMiddleware(sagaMiddleware));

  store.sagaTask = sagaMiddleware.run(rootSaga);
  store.close = () => store.dispatch(END);

  return store;
};
