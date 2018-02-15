import { lighten, darken } from 'polished';

const primary = 'hsla(212, 100%, 60%, 1)';
const primaryLight = lighten(0.1, primary);
const primaryDark = darken(0.1, primary);

const background = 'hsla(360, 100%, 100%, 1)';

const colors = {
  primary,
  primaryLight,
  primaryDark,
  background,
};

export default colors;
