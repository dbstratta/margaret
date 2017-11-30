import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import 'jest-styled-components';
import 'jest-enzyme';
import createHistory from 'history/createBrowserHistory';

import theme from './theme';
import configureStore from './store/configureStore';
import configureApollo from './configureApollo';

configure({ adapter: new Adapter() });

// Mock the styled-components theme.
global.theme = theme;

// Mock history.
global.history = createHistory();

// Mock Redux store.
global.store = configureStore({ history: global.history });

// Mock Apollo client.
global.client = configureApollo();

// Mock localStorage.
global.localStorage = {
  key: jest.fn(),
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
