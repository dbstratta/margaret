import { compose } from 'ramda';
import withRedux from 'next-redux-wrapper';

import withData from './withData';
import withReduxSaga from './withReduxSaga';
import withTopErrorBoundary from './withTopErrorBoundary';
import withStyledComponentsTheme from './withStyledComponentsTheme';
import configureStore from '../store';

/**
 * Composed HOC with HOCs that every page needs.
 */
export default compose(
  withData,
  withRedux(configureStore),
  withReduxSaga,
  withTopErrorBoundary,
  withStyledComponentsTheme,
);
