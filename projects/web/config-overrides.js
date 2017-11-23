const { compose, injectBabelPlugin } = require('react-app-rewired');
const rewireReactHotLoader = require('react-app-rewire-hot-loader');
const rewireStyledComponents = require('react-app-rewire-styled-components');
const rewirePolished = require('react-app-rewire-polished');

const rewireGraphQLTag = config => injectBabelPlugin('graphql-tag', config);
const rewireTransformDecorators = config => injectBabelPlugin('transform-decorators', config);

module.exports = compose(
  rewireReactHotLoader,
  rewireTransformDecorators,
  rewireGraphQLTag,
  rewireStyledComponents,
  rewirePolished,
);
