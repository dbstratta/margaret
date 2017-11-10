import { createStore, applyMiddleware } from 'redux';
import createSagaMiddleware from 'redux-saga';

import rootReducer from '../rootReducer';

const sagaMiddleware = createSagaMiddleware();

export default initialState => ({
  ...createStore(rootReducer, initialState, applyMiddleware(sagaMiddleware)),
  runSaga: sagaMiddleware.run,
});
