const { environment } = require('@rails/webpacker')
// https://stackoverflow.com/questions/54905026/how-to-add-jquery-third-party-plugin-in-rails-6-webpacker
environment.loaders.append('jquery', {
  test: require.resolve('jquery'),
  use: [{
    loader: 'expose-loader',
    options: '$',
  }, {
    loader: 'expose-loader',
    options: 'jQuery',
  }],
});

module.exports = environment
