/**
 * Adds a unit to a raw value.
 */
export const addUnit = unit => rawValue => `${rawValue}${unit}`;

/**
 * Adds the `rem` unit to a raw value.
 */
export const addRemUnit = addUnit('rem');

/**
 * Adds the `px` unit to a raw value.
 */
export const addPxUnit = addUnit('px');
