import { css } from 'styled-components';
import { curry, map, __ as _ } from 'ramda';

const baseSize = 0.2;
const sizes = {
  xs: `${baseSize * 3}rem`,
  sm: `${baseSize * 5}rem`,
  md: `${baseSize * 8}rem`,
  lg: `${baseSize * 13}rem`,
  xl: `${baseSize * 21}rem`,
};

// Spacing helpers
const spacing = curry((target, {
  top, right, bottom, left,
}) => css`
    ${top && `${target}-top: ${sizes[top]}`};
    ${right && `${target}-right: ${sizes[right]}`};
    ${bottom && `${target}-bottom: ${sizes[bottom]}`};
    ${left && `${target}-left: ${sizes[left]}`};
  `);

const spacingAll = target => size =>
  spacing(target, {
    top: size,
    right: size,
    bottom: size,
    left: size,
  });

const spacingTopBottom = target => size => spacing(target, { top: size, bottom: size });
const spacingRightLeft = target => size => spacing(target, { right: size, left: size });
const spacingSide = side => target => size => spacing(target, { [side]: size });

const sides = ['top', 'right', 'bottom', 'left'];
const [spacingTop, spacingRight, spacingBottom, spacingLeft] = map(spacingSide, sides);

const spacingHelpers = [
  spacing,
  spacingAll,
  spacingTopBottom,
  spacingRightLeft,
  spacingTop,
  spacingRight,
  spacingBottom,
  spacingLeft,
];

const [marginCreator, paddingCreator] = map(target => fn => fn(target), ['margin', 'padding']);

const helperCreator = map(_, spacingHelpers);

// Margin helpers
const [
  margin,
  marginAll,
  marginTopBottom,
  marginRightLeft,
  marginTop,
  marginRight,
  marginBottom,
  marginLeft,
] = helperCreator(marginCreator);

// Padding helpers
const [
  padding,
  paddingAll,
  paddingTopBottom,
  paddingRightLeft,
  paddingTop,
  paddingRight,
  paddingBottom,
  paddingLeft,
] = helperCreator(paddingCreator);

export default {
  sizes,
  margin,
  marginAll,
  marginTopBottom,
  marginRightLeft,
  marginTop,
  marginRight,
  marginBottom,
  marginLeft,
  padding,
  paddingAll,
  paddingTopBottom,
  paddingRightLeft,
  paddingTop,
  paddingRight,
  paddingBottom,
  paddingLeft,
};
