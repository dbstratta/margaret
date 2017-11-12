module.exports = {
  root: true,
  parser: 'babel-eslint',
  parserOptions: {
    ecmaVersion: 2017,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },

  plugins: ['prettier', 'react', 'graphql'],

  env: {
    es6: true,
    browser: true,
    jest: true,
  },

  extends: [
    'eslint:recommended',
    'plugin:jsx-a11y/recommended',
    'plugin:react/recommended',
    'prettier',
    'prettier/react',
    'airbnb',
  ],

  rules: {
    'react/jsx-filename-extension': ['warn', { extensions: ['.js', '.jsx'] }],
    'react/forbid-prop-types': 'off',

    'import/no-named-as-default': 'off',
    'import/no-extraneous-dependencies': 'off',

    'jsx-a11y/anchor-is-valid': 'off',
  },
};
