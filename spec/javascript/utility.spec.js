import Utility from 'utility';

describe('Utility.countrySelectorOnConfirm', () => {
  let selectElement, form, anchorInput, originalLocation;

  beforeEach(() => {
    // Save the original location so we can restore it after the test
    originalLocation = window.location;

    // Mock the window location
    delete window.location;
    window.location = {
      href: '',
      hash: '#origin',
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
    anchorInput = selectElement.closest('.govuk-fieldset').querySelector('input[name$="[anchor]"]');
  });

  afterEach(() => {
    // Restore the original location
    window.location = originalLocation;
  });

  it('navigates to the URL for "All countries"', () => {
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
    expect(anchorInput.value).toBe('origin');
    expect(form.submit).toHaveBeenCalled();
  });

  it('navigates to the URL with service "xi" for "All countries"', () => {
    // Set the service to 'xi'
    document.getElementById('trading_partner_service').value = 'xi';

    const confirmed = 'All countries';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(window.location.href).toBe(`${window.location.origin}/xi/commodities/1234#origin`);
  });
});

describe('Utility.fetchCommoditySearchSuggestions', () => {
  beforeEach(() => {
    global.fetch = jest.fn();
  });

  afterEach(() => {
    jest.resetAllMocks();
  });

  it('fetches suggestions and populates results', async () => {
    const mockResponse = {
      results: [
        { id: 'wine', text: 'wine', query: 'wine', resource_id: '6828', formatted_suggestion_type: '' },
        { id: 'red wine', text: 'red wine', query: 'wine', resource_id: '7273', formatted_suggestion_type: '' },
      ],
    };

    global.fetch.mockResolvedValue({
      json: jest.fn().mockResolvedValue(mockResponse),
    });

    const query = 'wine';
    const searchSuggestionsPath = '/test-path';
    const options = [];
    const populateResults = jest.fn();

    await Utility.fetchCommoditySearchSuggestions(query, searchSuggestionsPath, options, populateResults);

    expect(fetch).toHaveBeenCalledWith(`${searchSuggestionsPath}?term=wine`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const expectedResults = [
      { id: 'wine', text: 'wine', suggestion_type: 'exact', newOption: true },
      ...mockResponse.results,
    ];

    expect(options).toEqual(expectedResults);
  });

  it('handles fetch error gracefully', async () => {
    global.fetch.mockRejectedValue(new Error('Fetch error'));

    const query = 'wine';
    const searchSuggestionsPath = '/test-path';
    const options = [];
    const populateResults = jest.fn();

    await Utility.fetchCommoditySearchSuggestions(query, searchSuggestionsPath, options, populateResults);

    expect(fetch).toHaveBeenCalledWith(`${searchSuggestionsPath}?term=wine`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    expect(populateResults).toHaveBeenCalledWith([]);
  });
});

describe('Utility.commoditySelectorOnConfirm', () => {
  let options, resourceIdHidden, inputElement, form;

  beforeEach(() => {
    options = [
      { "id": "wine", "text": "wine", "suggestion_type": "exact", "newOption": true },
      { "id": "wine", "text": "wine", "query": "wine", "resource_id": "6828", "formatted_suggestion_type": "" }
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
    const text = { id: 'wine', text: 'wine' };

    Utility.commoditySelectorOnConfirm(text, options, resourceIdHidden, inputElement);

    expect(resourceIdHidden.value).toBe('6828');
    expect(inputElement.value).toBe('wine');
    expect(form.submit).toHaveBeenCalled();
  });

  it('does nothing if the selected option is not found', () => {
    const text = { id: '3', text: 'Unknown Commodity' };

    Utility.commoditySelectorOnConfirm(text, options, resourceIdHidden, inputElement);

    expect(resourceIdHidden.value).toBe('');
    expect(inputElement.value).toBe('');
    expect(form.submit).not.toHaveBeenCalled();
  });
});
