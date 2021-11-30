import TradingPartnerAutocomplete from '../src/javascripts/country-autocomplete';

var tradingPartnerAutocomplete = new TradingPartnerAutocomplete();
var target = document.querySelector('[id^="trading-partner-country-field"]')

tradingPartnerAutocomplete.enhanceElement(target);
