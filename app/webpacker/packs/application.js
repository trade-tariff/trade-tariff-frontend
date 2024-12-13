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
require.context('images/');

import './application.scss';
import 'core-js/stable';
import 'regenerator-runtime/runtime';

import jQuery from 'jquery';
window.$ = jQuery;
window.jQuery = jQuery;

require('popup');
require('select2');
require('jquery-migrate');
require('jquery.history');
require('jquery-next-id/jquery.nextid');
require('jquery-roving-tabindex/jquery.rovingtabindex');
require('jquery-tabs/jquery.tabs');
require('mark.js/dist/jquery.mark');

require('../src/javascripts/datepicker-day.js');
require('../src/javascripts/calendar-button.js');
require('../src/javascripts/datepicker.js');
require('../src/javascripts/help_popup.js');
require('../src/javascripts/google-tag-manager-loader.js');
require('../src/javascripts/commodities.js');
// TODO test:
require('../src/javascripts/country-autocomplete.js');
require('../src/javascripts/quota-search.js');
require('../src/javascripts/stop-scrolling-at-footer.js');

import debounce from '../src/javascripts/debounce.js';
import Utility from '../src/javascripts/utility.js';
import accessibleAutocomplete from 'accessible-autocomplete';

window.Utility = Utility;
window.debounce = debounce;
window.accessibleAutocomplete = accessibleAutocomplete;

require.context('govuk-frontend/dist/govuk/assets');
import {initAll} from 'govuk-frontend/dist/govuk/govuk-frontend.min.js';
initAll();

// load Stimulus controllers
import 'controllers';

// eslint-disable-next-line no-undef
$(function() {
  // eslint-disable-next-line no-undef
  GOVUK.tariff.onLoad();
  window.Utility = Utility;
  window.debounce = debounce;
});
