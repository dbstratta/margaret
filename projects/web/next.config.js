const webpack = require('webpack');
const { concat } = require('ramda');

const { ANALYZE_BUNDLE } = process.env;

module.exports = {
  webpack: (config) => {
    const additionalPlugins = [new webpack.EnvironmentPlugin(process.env)];

    if (ANALYZE_BUNDLE) {
      // eslint-disable-next-line global-require
      const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
      additionalPlugins.push(new BundleAnalyzerPlugin());
    }

    return { ...config, plugins: concat(config.plugins, additionalPlugins) };
  },
};
