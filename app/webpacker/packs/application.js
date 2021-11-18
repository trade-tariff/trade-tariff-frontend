/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
require.context('images/flags');
require.context('images/');

import './application.scss';
import "core-js/stable";
import "regenerator-runtime/runtime";

import IMask from 'imask';
import jQuery from 'jquery'
window.$ = jQuery;
window.jQuery = jQuery;

require('../src/javascripts/sentry.js');

require('popup');
require('select2');
require('jquery-migrate');
require('jquery.history');
require('jquery-next-id/jquery.nextid');
require('jquery-roving-tabindex/jquery.rovingtabindex');
require('jquery-tabs/jquery.tabs');
require('mark.js/dist/jquery.mark');

// console.log('popup');
// console.log(BetaPopup);
// BetaPopup.popup('title', 'tariff-info');
// console.log(
//   require('jquery-debouncedresize')
// );
// console.log(
//   import('jquery-debouncedresize')
// );
// require('./node_modules/jquery-history/dist/jquery.history');
// require('../../../node_modules/jquery-history/dist/jquery.history');
// require('jquery-history/dist/jquery.history');
require('../src/javascripts/datepicker-day.js');
require('../src/javascripts/calendar-button.js');
require('../src/javascripts/datepicker.js');

import accessibleAutocomplete from 'accessible-autocomplete';
window.accessibleAutocomplete = accessibleAutocomplete;

require('../src/javascripts/commodities.js');
// TODO test:
require('../src/javascripts/exchange_rate.js');
require('../src/javascripts/feedback.js');
require('../src/javascripts/quota-search.js');
require('../src/javascripts/stop-scrolling-at-footer.js');

require.context('govuk-frontend/govuk/assets');
import { initAll } from 'govuk-frontend';

initAll();

$(function(){
  GOVUK.tariff.onLoad();
});
