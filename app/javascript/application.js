import debounce from 'debounce';
import accessibleAutocomplete from 'accessible-autocomplete'
import jQuery from 'jquery';
import "controllers"
import { initAll } from 'govuk-frontend';
import { initializeSearchAutocompletes } from 'search-autocomplete';
import Utility from 'utility';

initAll();

window.$ = jQuery;
window.jQuery = jQuery;

window.GOVUK = {};
window.GOVUK.Utility = Utility;
window.GOVUK.debounce = debounce;
window.GOVUK.accessibleAutocomplete = accessibleAutocomplete;

initializeSearchAutocompletes(document, {
  accessibleAutocomplete,
  debounce,
  fetchSuggestions: (...args) => Utility.fetchCommoditySearchSuggestions(...args),
});

import 'quota-search'
import 'country-of-origin'
import 'other-country-of-origin'
import 'help_popup'
import 'commodities'
