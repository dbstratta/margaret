import React from 'react';
import { ThemeProvider } from 'styled-components';
import { hoistStatics, setDisplayName } from 'recompose';

const theme = {};

const enhance = setDisplayName('ThemeProviderWrapper');

export default hoistStatics(WrappedPage =>
  enhance(props => (
    <ThemeProvider theme={theme}>
      <WrappedPage {...props} />
    </ThemeProvider>
  )));
