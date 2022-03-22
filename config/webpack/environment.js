const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  BetaPopup: 'popup'
}));

module.exports = environment;
