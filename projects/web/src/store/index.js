if (process.env.NODE_ENV === 'production') {
  // eslint-disable-next-line global-require
  module.exports = require('./configureStore');
} else {
  // eslint-disable-next-line global-require
  module.exports = require('./configureStore.dev');
}
