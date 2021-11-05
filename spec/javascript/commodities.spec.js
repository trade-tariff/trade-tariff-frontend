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

describe('searchForm', () => {
  const autocompleteSelector = '.autocomplete__wrapper input';

  const commodityPickerTemplate = `
    <div class="search-header js-search-header">
      <input type="text" name="q" class="js-commodity-picker-target" />
      <div class='js-commodity-picker-select js-show'></div>

      <input type="input" name="day" id="tariff_date_day" />
      <input type="input" name="month" id="tariff_date_month" />
      <input type="input" name="year" id="tariff_date_year" />

      <input type="submit" value="Search" />
    </div>
  `;

  beforeEach(() => {
    document.body.innerHTML = commodityPickerTemplate;
    GOVUK.tariff.selectBoxes.initialize(document.body);
  });

  it('loads the autocomplete', () => {
    const autocompleteWidgets = document.querySelectorAll(autocompleteSelector);
    expect(autocompleteWidgets.length).toBe(1);
  });
});
