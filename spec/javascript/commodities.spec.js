// There are tests for commodities.js
// To run them: 'yarn test' .

global.accessibleAutocomplete = require('accessible-autocomplete');
require('commodities.js');

test('GOVUK.tariff public has expected public methods', () => {
  const items = [
    'breadcrumbs',
    'copyCode',
    'countryPicker',
    'hovers',
    'measuresTable',
    'searchForm',
    'searchHighlight',
    'tabLinkFocuser',
    'tablePopup',
    'tabs',
  ];

  items.forEach( (item) => {
    expect(GOVUK.tariff).toHaveProperty(item);
  });
});
