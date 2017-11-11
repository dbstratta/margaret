const nextRouter = require('next-routes');

const routes = nextRouter();

routes
  .add({ name: 'index', pattern: '/', page: 'index' })
  .add({ name: 'newStory', pattern: '/new', page: 'new' });

module.exports = routes;
