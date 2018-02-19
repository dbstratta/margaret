/**
 * Viewport width breakpoints in pixels.
 *
 * The breakpoint values were extracted from Bootstrap 4.
 */

import { addPxUnit } from './helpers';

/**
 * The raw breakpoints are the breakpoint values without the unit.
 * They're useful for adding to other values and then appending the unit.
 */
const rawBreakpoints = {
  xs: 0,
  sm: 576,
  md: 768,
  lg: 992,
  xl: 1200,
  xxl: 1900,
};

/**
 * The breakpoints are just the raw breakpoints with `px` appended to them.
 */
const breakpoints = Object.entries(rawBreakpoints).reduce(
  (acc, [breakpoint, rawValue]) => ({ ...acc, [breakpoint]: addPxUnit(rawValue) }),
  {},
);

export default {
  rawBreakpoints,
  ...breakpoints,
};
