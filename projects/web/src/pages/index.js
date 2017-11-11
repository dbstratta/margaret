import React from 'react';

import { withPageInit } from '../hocs';

const Index = () => <h1>Index</h1>;

const enhance = withPageInit;

export default enhance(Index);
