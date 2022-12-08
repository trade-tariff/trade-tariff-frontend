const { environment } = require('@rails/webpacker');
const { execSync } = require('child_process')
const webpack = require('webpack');

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  BetaPopup: 'popup'
}));

let gpcGemPath = null
try {
  gpcGemPath = execSync('bundle show govuk_publishing_components')
    .toString()
    .replace(/\n$/, '')
} catch (err) {
  console.error("Expected govuk_publishing_components gem to be installed")
  process.exit()
}

const config = environment.toWebpackConfig()
config.resolve.modules.push(`${gpcGemPath}/app/assets/images/govuk_publishing_components`)
config.resolve.modules.push(`${gpcGemPath}/app/assets/stylesheets/govuk_publishing_components`)
config.resolve.modules.push(`${gpcGemPath}/app/assets/javascripts/govuk_publishing_components`)

module.exports = environment;
