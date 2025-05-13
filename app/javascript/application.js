import debounce from 'debounce';
import Utility from 'utility';
import accessibleAutocomplete from 'accessible-autocomplete';
import jQuery from 'jquery';

import "@hotwired/turbo-rails"
import "controllers"

import 'core-js/stable'

import { initAll } from 'govuk-frontend';
initAll();

window.$ = jQuery;
window.jQuery = jQuery;

window.GOVUK = window.GOVUK || {};
window.GOVUK.Utility = Utility;
window.GOVUK.debounce = debounce;
window.GOVUK.accessibleAutocomplete = accessibleAutocomplete;

import 'quota-search'
