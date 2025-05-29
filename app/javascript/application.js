import debounce from 'debounce';
import accessibleAutocomplete from 'accessible-autocomplete'
import jQuery from 'jquery';
import "controllers"
import { initAll } from 'govuk-frontend';

initAll();

window.$ = jQuery;
window.jQuery = jQuery;

window.GOVUK = {};
window.GOVUK.Utility = Utility;
window.GOVUK.debounce = debounce;
window.GOVUK.accessibleAutocomplete = accessibleAutocomplete;

import Utility from 'utility';
import 'quota-search'
import 'trading-partner-autocomplete'
import 'country-of-origin'
import 'other-country-of-origin'
import 'help_popup'
import 'commodities'
