import CountryAutocomplete from '../packs/country_autocomplete';

var country_autocomplete = new CountryAutocomplete();
var target = document.querySelector('[id^="steps-country-of-origin-other-country-of-origin-field"]')

country_autocomplete.enhanceElement(target);
