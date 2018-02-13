/**
 * The base raw value is the value we base the rest of the values on.
 */
const baseRawValue = 0.2;

/**
 * Adds a unit to a raw value.
 */
const addUnit = unit => rawValue => `${rawValue}${unit}`;

/**
 * Adds the `rem` unit to a raw value.
 */
const addRemUnit = addUnit('rem');

/**
 * The raw sizes are the sizes without the unit.
 * They're useful for adding to other values and then appending the unit.
 */
const rawSizes = {
  xs: baseRawValue * 3,
  sm: baseRawValue * 5,
  md: baseRawValue * 8,
  lg: baseRawValue * 13,
  xl: baseRawValue * 21,
};

/**
 * The sizes are just the raw sizes with `rem` appended to them.
 */
const sizes = Object.entries(rawSizes).reduce(
  (acc, [size, rawValue]) => ({ ...acc, [size]: addRemUnit(rawValue) }),
  {},
);

export default {
  sizes,
  rawSizes,
  addRemUnit,
};
