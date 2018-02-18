import { injectGlobal } from 'styled-components';

import theme from './theme';

// eslint-disable-next-line no-unused-expressions
injectGlobal`
  :root {
    --primary-color: hsla(212, 100%, 60%, 1);
    --background-color: hsla(360, 100%, 100%, 1);

    --sans-serif-font-family: 'Open Sans', sans-serif;
    --serif-font-family: 'Open Sans', sans-serif;

    --xs-font-size: 0.8rem;
    --sm-font-size: 0.82rem;
    --md-font-size: 1rem;
    --lg-font-size: 1.4rem;
    --xl-font-size: 2.5rem;

    --primary-font-color: hsla(0, 0%, 0%, 0.84);
    --secondary-font-color: hsla(0, 0%, 0%, 0.54);
    --tertiary-font-color: hsla(0, 0%, 0%, 0.15);

    --base-space: 0.2rem;
    --xs-space: calc(var(--base-space) * 3);
    --sm-space: calc(var(--base-space) * 5);
    --md-space: calc(var(--base-space) * 8);
    --lg-space: calc(var(--base-space) * 13);
    --xl-space: calc(var(--base-space) * 21);

    --main-content-width: 95%;

    --xs-breakpoint: 0;
    --sm-breakpoint: 576px;
    --md-breakpoint: 768px;
    --lg-breakpoint: 992px;
    --xl-breakpoint: 1200px;
  }

  * {
    box-sizing: border-box;
  }

  html {
    font-family: var(--sans-serif-font-family);
    color: var(--primary-font-color);
  }

  body {
    margin: 0;
  }

  @media (min-width: ${theme.breakpoints.sm}) {
    :root {
      --main-content-width: 90%;
    }
  }

  @media (min-width: ${theme.breakpoints.xl}) {
    :root {
      --main-content-width: 70%;
    }
  }
`;
