import debounce from 'debounce';
import Utility from 'src/utility';
import accessibleAutocomplete from 'accessible-autocomplete';
import jQuery from 'jquery';

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
import 'commodities'
// {
//   "imports": {
//     "@hotwired/stimulus": "/assets/stimulus.min-4b1e420e.js",
//     "@hotwired/stimulus-loading": "/assets/stimulus-loading-1fc53fe7.js",
//     "core-js/stable": "https://ga.jspm.io/npm:core-js@3.42.0/stable/index.js",
//     "govuk-frontend": "https://cdn.jsdelivr.net/npm/govuk-frontend@5.10.0/+esm",
//     "mark.js": "/assets/mark.js-953a14dd.js",
//     "select2": "/assets/select2-b320a869.js",
//     "jquery": "/assets/jquery-15a62848.js",
//     "accessible-autocomplete": "/assets/accessible-autocomplete-c73ef825.js",
//     "debounce": "/assets/debounce-34e8e554.js",
//     "jquery-migrate": "/assets/jquery-migrate-62cebb96.js",
//     "js-cookie": "/assets/js-cookie-2e5a6772.js",
//     "application": "/assets/application-b93911f8.js",
//     "controllers/anchor_controller": "/assets/controllers/anchor_controller-3d46924a.js",
//     "controllers/application": "/assets/controllers/application-3affb389.js",
//     "controllers/chapter_selection_controller": "/assets/controllers/chapter_selection_controller-8e82e0c2.js",
//     "controllers/cookie_banner_controller": "/assets/controllers/cookie_banner_controller-4e7ebb1a.js",
//     "controllers/cookie_policy_controller": "/assets/controllers/cookie_policy_controller-41e0b458.js",
//     "controllers/country_select_box_controller": "/assets/controllers/country_select_box_controller-3c11d3da.js",
//     "controllers/faq_controller": "/assets/controllers/faq_controller-c2f4de23.js",
//     "controllers/highlighter_controller": "/assets/controllers/highlighter_controller-a15816b7.js",
//     "controllers": "/assets/controllers/index-ee64e1f1.js",
//     "controllers/modal_controller": "/assets/controllers/modal_controller-9b550fe2.js",
//     "controllers/pending_balance_controller": "/assets/controllers/pending_balance_controller-40fb18f6.js",
//     "controllers/step_by_step_nav_controller": "/assets/controllers/step_by_step_nav_controller-09f29436.js",
//     "controllers/tree_controller": "/assets/controllers/tree_controller-0c3ceadb.js",
//     "controllers/uk_only_controller": "/assets/controllers/uk_only_controller-5b76a581.js",
//     "src/commodities": "/assets/src/commodities-cd9a1ae6.js",
//     "src/cookie-manager": "/assets/src/cookie-manager-8bc70bf9.js",
//     "src/country-autocomplete": "/assets/src/country-autocomplete-59ad276e.js",
//     "src/help_popup": "/assets/src/help_popup-6d6d1a1e.js",
//     "src/quota-search": "/assets/src/quota-search-a611dcd4.js",
//     "src/step-by-step-nav": "/assets/src/step-by-step-nav-f0919b07.js",
//     "src/trading-partner-autocomplete": "/assets/src/trading-partner-autocomplete-94dad645.js",
//     "src/utility": "/assets/src/utility-7e1989a7.js",
//     "src/vendor/jquery.nextid.min": "/assets/src/vendor/jquery.nextid.min-b2ac768e.js",
//     "src/vendor/jquery.rovingtabindex.min": "/assets/src/vendor/jquery.rovingtabindex.min-10e5c885.js",
//     "src/vendor/jquery.tabs.min": "/assets/src/vendor/jquery.tabs.min-6a2e1d33.js"
//   }
// }
