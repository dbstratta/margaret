import * as auth from './auth';

/**
 * Truncates a string.
 */
const truncateString = (string, max) => {
  if (string.length <= max) {
    return string;
  }

  return string
    .substr(0, max)
    .trim()
    .concat('...');
};

// eslint-disable-next-line import/prefer-default-export
export { auth, truncateString };
