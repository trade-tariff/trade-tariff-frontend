// There are tests for commodities.js
// To run them: 'yarn test' .

require('commodities.js');

test('GOVUK.tariff public has expected public methods', () => {
  const items = ['tree', 
                  'tabs', 
                  'tablePopup', 
                  'tabLinkFocuser', 
                  'hovers', 
                  'selectBoxes', 
                  'searchForm', 
                  'searchHighlight', 
                  'countryPicker', 
                  'breadcrumbs', 
                  'measuresTable', 
                  'copyCode']

  items.forEach( (item) => {
    expect(GOVUK.tariff).toHaveProperty(item)
  });
});
