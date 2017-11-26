const { compose, injectBabelPlugin } = require('react-app-rewired');
const rewireReactHotLoader = require('react-app-rewire-hot-loader');
const rewireStyledComponents = require('react-app-rewire-styled-components');
const rewirePolished = require('react-app-rewire-polished');

const rewireBabelPlugin = pluginName => config => injectBabelPlugin(pluginName, config);

const rewireGraphQLTag = rewireBabelPlugin('graphql-tag');
const rewireTransformDecoratorsLegacy = rewireBabelPlugin('transform-decorators-legacy');

module.exports = compose(
  rewireReactHotLoader,
  rewireGraphQLTag,
  rewireStyledComponents,
  rewirePolished,
  rewireTransformDecoratorsLegacy,
);
