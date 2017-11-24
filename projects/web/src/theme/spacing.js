import { css } from 'styled-components';
import { curry } from 'ramda';

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

const spacingTop = spacingSide('top');
const spacingRight = spacingSide('right');
const spacingBottom = spacingSide('bottom');
const spacingLeft = spacingSide('left');

const spacingCreator = target => fn => fn(target);
const marginCreator = spacingCreator('margin');
const paddingCreator = spacingCreator('padding');

// Margin helpers
const margin = marginCreator(spacing);
const marginAll = marginCreator(spacingAll);
const marginTopBottom = marginCreator(spacingTopBottom);
const marginRightLeft = marginCreator(spacingRightLeft);
const marginTop = marginCreator(spacingTop);
const marginRight = marginCreator(spacingRight);
const marginBottom = marginCreator(spacingBottom);
const marginLeft = marginCreator(spacingLeft);

// Padding helpers
const padding = paddingCreator(spacing);
const paddingAll = paddingCreator(spacingAll);
const paddingTopBottom = paddingCreator(spacingTopBottom);
const paddingRightLeft = paddingCreator(spacingRightLeft);
const paddingTop = paddingCreator(spacingTop);
const paddingRight = paddingCreator(spacingRight);
const paddingBottom = paddingCreator(spacingBottom);
const paddingLeft = paddingCreator(spacingLeft);

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
