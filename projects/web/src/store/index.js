/* eslint-disable global-require */
if (process.env.NODE_ENV === 'production') {
  module.exports = require('./configureStore');
} else {
  module.exports = require('./configureStore.dev');
}
