import React from 'react';
import Link from 'next/link';
import styled from 'styled-components';

import { withPageInit } from '../hocs';

const StyledSpan = styled.span`
  color: #0f0;
`;

export const Index = () => (
  <h1>
    <StyledSpan>Index</StyledSpan>
    <Link href="/new">
      <a>new</a>
    </Link>
  </h1>
);

const enhance = withPageInit;

export default enhance(Index);
