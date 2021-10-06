// There are tests for commodities.js
// To run them: 'yarn test' .

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
    'selectBoxes',
    'tabLinkFocuser',
    'tablePopup',
    'tabs',
    'tree',
  ];

  items.forEach( (item) => {
    expect(GOVUK.tariff).toHaveProperty(item);
  });
});
