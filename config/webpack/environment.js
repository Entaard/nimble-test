const { environment } = require('@rails/webpacker')
const webpack = require('webpack');

const plugins = [
  new webpack.ProvidePlugin({
    // Translations
    I18n: 'i18n-js',
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    jquery: 'jquery/src/jquery',
    Popper: ['popper.js', 'default']
  })
];

environment.config.set('plugins', plugins);

module.exports = environment
