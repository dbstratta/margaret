import { lighten, darken } from 'polished';

const primary = 'hsla(212, 100%, 60%, 1)';
const primaryLight = lighten(0.1, primary);
const primaryDark = darken(0.1, primary);

export default {
  primary,
  primaryLight,
  primaryDark,
};
