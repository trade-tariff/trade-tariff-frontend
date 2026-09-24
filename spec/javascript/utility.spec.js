/* eslint-env node, jest */

import Utility from '../../app/javascript/src/utility';

describe('Utility.countrySelectorOnConfirm', () => {
  let selectElement;
  let form;

  beforeEach(() => {
    document.body.innerHTML = `
      <form>
        <div class="govuk-fieldset">
          <select>
            <option value=" ">All countries</option>
            <option value="AF">Afghanistan (AF)</option>
            <option value="ZW">Zimbabwe (ZW)</option>
          </select>
        </div>
      </form>
    `;

    selectElement = document.querySelector('select');
    form = selectElement.closest('form');
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('selects "All countries" without updating the page', () => {
    selectElement.value = 'AF';
    form.submit = jest.fn();

    Utility.countrySelectorOnConfirm('All countries', selectElement);

    expect(selectElement.value).toBe(' ');
    expect(form.submit).not.toHaveBeenCalled();
  });

  it('selects a specific country without updating the page', () => {
    form.submit = jest.fn();
    const changeHandler = jest.fn();
    selectElement.addEventListener('change', changeHandler);

    Utility.countrySelectorOnConfirm('Afghanistan (AF)', selectElement);

    expect(selectElement.value).toBe('AF');
    expect(changeHandler).toHaveBeenCalledTimes(1);
    expect(form.submit).not.toHaveBeenCalled();
  });

  it('does not change the selection for an unrecognised country', () => {
    selectElement.value = 'ZW';

    Utility.countrySelectorOnConfirm('Unknown country', selectElement);

    expect(selectElement.value).toBe('ZW');
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
