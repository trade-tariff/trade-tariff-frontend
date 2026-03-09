/* eslint-env node, jest */

import Utility from '../../app/javascript/src/utility';

describe('Utility.countrySelectorOnConfirm', () => {
  let selectElement;
  let form;
  let navigateSpy;

  beforeEach(() => {
    // Spy on Utility.navigate so we can assert where it navigated without
    // triggering jsdom's "Not implemented: navigation" error
    navigateSpy = jest.spyOn(Utility, 'navigate').mockImplementation(() => {});

    // Use history.pushState to control window.location.hash and .pathname —
    // jsdom supports this without triggering navigation
    window.history.pushState({}, '', '/#origin');

    document.body.innerHTML = `
      <div class="commodity-header" data-comm-code="1234"></div>
      <form>
        <div class="govuk-fieldset">
          <select>
            <option value="AF">(AF)</option>
            <option value="ZW">(ZW)</option>
          </select>
        </div>
      </form>
    `;

    selectElement = document.querySelector('select');
    form = selectElement.closest('form');
  });

  afterEach(() => {
    jest.restoreAllMocks();
    window.history.pushState({}, '', '/');
  });

  it('navigates to the URL for "All countries"', () => {
    Utility.countrySelectorOnConfirm('All countries', selectElement);

    expect(navigateSpy).toHaveBeenCalledWith('/commodities/1234#origin');
  });

  it('sets the select element value and submits the form for a specific country', () => {
    form.submit = jest.fn();

    Utility.countrySelectorOnConfirm('Afghanistan (AF)', selectElement);

    expect(selectElement.value).toBe('AF');
    expect(form.submit).toHaveBeenCalled();
  });

  it('navigates to the URL with service "xi" for "All countries"', () => {
    window.history.pushState({}, '', '/xi/commodities/1234#origin');

    Utility.countrySelectorOnConfirm('All countries', selectElement);

    expect(navigateSpy).toHaveBeenCalledWith('/xi/commodities/1234#origin');
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
