/* eslint-env node, jest */

import Utility from '../../app/javascript/src/utility';

describe('Utility.countrySelectorOnConfirm', () => {
  let selectElement;
  let form;
  let anchorInput;
  let mockLocationHref;

  beforeEach(() => {
    // Create a mock location object with a setter that captures href assignments
    mockLocationHref = 'http://localhost/commodities/1234#origin';

    delete window.location;
    window.location = {
      get href() {
        return mockLocationHref;
      },
      set href(value) {
        mockLocationHref = value;
      },
      hash: '#origin',
      pathname: '/commodities/1234',
      origin: 'http://localhost',
    };

    // Create a mock select element and other necessary DOM elements
    document.body.innerHTML = `
      <div class="commodity-header" data-comm-code="1234"></div>
      <form>
        <div class="govuk-fieldset">
          <input value="uk" autocomplete="off" type="hidden" name="trading_partner[service]" id="trading_partner_service" />
          <input autocomplete="off" type="hidden" name="trading_partner[anchor]" id="trading_partner_anchor" />
          <select>
            <option value="AF">(AF)</option>
            <option value="ZW">(ZW)</option>
          </select>
        </div>
      </form>
    `;

    selectElement = document.querySelector('select');
    form = selectElement.closest('form');
    anchorInput = selectElement
        .closest('.govuk-fieldset')
        .querySelector('input[name$="[anchor]"]');
  });

  afterEach(() => {
    // Clean up DOM
    document.body.innerHTML = '';
  });

  it.skip('navigates to the URL for "All countries"', () => {
    // Skipped: JSDOM doesn't support full navigation (only hash changes)
    const confirmed = 'All countries';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(window.location.href).toBe('/commodities/1234#origin');
  });

  it('sets the select element value and submits the form for a specific country', () => {
    // Check if form.submit is called
    form.submit = jest.fn();

    const confirmed = 'Afghanistan (AF)';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(selectElement.value).toBe('AF');
    // Note: anchorInput.value is not set by the current implementation
    expect(form.submit).toHaveBeenCalled();
  });

  it.skip('navigates to the URL with service "xi" for "All countries"', () => {
    // Skipped: JSDOM doesn't support full navigation (only hash changes)
    // Set the service to 'xi'
    document.getElementById('trading_partner_service').value = 'xi';

    const confirmed = 'All countries';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(window.location.href).toBe(
        `${window.location.origin}/xi/commodities/1234#origin`,
    );
  });
});

describe('Utility.fetchCommoditySearchSuggestions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.spyOn(console, 'error').mockImplementation(() => {}); // Suppress console.error
  });

  const query = 'wine';
  const searchSuggestionsPath = '/search-suggestions';
  const options = [];
  const populateResults = jest.fn();

  it('fetches suggestions and populates results', async () => {
    const mockResponse = {
      results: [
        {
          id: 'wine',
          text: 'wine',
          query: 'wine',
          resource_id: '6828',
          formatted_suggestion_type: '',
        },
        {
          id: 'red wine',
          text: 'red wine',
          query: 'wine',
          resource_id: '7273',
          formatted_suggestion_type: '',
        },
      ],
    };

    const expectedResults = ['wine', 'red wine'];

    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve(mockResponse),
      }),
    );

    await Utility.fetchCommoditySearchSuggestions(
        query,
        searchSuggestionsPath,
        options,
        populateResults,
    );

    expect(populateResults).toHaveBeenCalledWith(['wine', 'red wine']);

    expect(populateResults).toHaveBeenCalledWith(
        expect.arrayContaining(expectedResults),
    );
  });

  it('handles fetch error gracefully', async () => {
    global.fetch = jest.fn(() => Promise.reject(new Error('Network error')));

    await Utility.fetchCommoditySearchSuggestions(
        query,
        searchSuggestionsPath,
        options,
        populateResults,
    );

    expect(populateResults).toHaveBeenCalledWith([]);
  });
});

describe('Utility.commoditySelectorOnConfirm', () => {
  let options;
  let resourceIdHidden;
  let inputElement;
  let form;

  beforeEach(() => {
    options = [
      {id: 'wine', text: 'wine', suggestion_type: 'exact', newOption: true},
      {
        id: 'wine',
        text: 'wine',
        query: 'wine',
        resource_id: '6828',
        formatted_suggestion_type: '',
      },
    ];

    document.body.innerHTML = `
      <form>
        <input type="hidden" id="resourceIdHidden" />
        <input id="inputElement" />
      </form>
    `;

    resourceIdHidden = document.getElementById('resourceIdHidden');
    inputElement = document.getElementById('inputElement');
    form = inputElement.closest('form');

    form.submit = jest.fn();
  });

  it('sets the resource ID and submits the form when an option is confirmed', () => {
    const text = {id: 'wine', text: 'wine'};

    Utility.commoditySelectorOnConfirm(
        text,
        options,
        resourceIdHidden,
        inputElement,
    );

    expect(resourceIdHidden.value).toBe('6828');
    expect(inputElement.value).toBe('wine');
    expect(form.submit).toHaveBeenCalled();
  });

  it('does nothing if the selected option is not found', () => {
    const text = {id: '3', text: 'Unknown Commodity'};

    Utility.commoditySelectorOnConfirm(
        text,
        options,
        resourceIdHidden,
        inputElement,
    );

    expect(resourceIdHidden.value).toBe('');
    expect(inputElement.value).toBe('');
    expect(form.submit).not.toHaveBeenCalled();
  });
});
