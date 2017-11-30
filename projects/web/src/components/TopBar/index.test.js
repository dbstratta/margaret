import React from 'react';
import { shallow } from 'enzyme';

import { TopBar } from '.';

describe('<TopBar />', () => {
  it('should render without crashing', () => {
    shallow(<TopBar />);
  });
});
