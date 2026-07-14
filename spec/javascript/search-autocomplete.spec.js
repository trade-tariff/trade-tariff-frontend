/* eslint-env node, jest */

import {
  initializeSearchAutocomplete,
  initializeSearchAutocompletes,
} from '../../app/javascript/src/search-autocomplete';

describe('initializeSearchAutocomplete', () => {
  let autocompleteConfig;
  let autocompleteInput;
  let debounce;
  let form;
  let fetchSuggestions;
  let populateResults;

  const typeQuery = (query) => {
    autocompleteInput.value = query;
    autocompleteInput.dispatchEvent(new Event('input', { bubbles: true }));
  };

  const requestSuggestions = (query, suggestions) => {
    autocompleteConfig.source(query, jest.fn());
    populateResults(suggestions);
  };

  beforeEach(() => {
    document.body.innerHTML = `
      <form id="new_search">
        <div
          id="autocomplete"
          data-input-id="search-q-field"
          data-input-name="q"
        ></div>
      </form>
      <div class="path_info" data-search-suggestions-path="/search_suggestions.json"></div>
    `;

    form = document.querySelector('form');
    form.submit = jest.fn();
    debounce = jest.fn((callback) => callback);
    fetchSuggestions = jest.fn((_query, _path, _options, populate) => {
      populateResults = populate;
    });

    const accessibleAutocomplete = jest.fn((config) => {
      autocompleteConfig = config;
      autocompleteInput = document.createElement('input');
      autocompleteInput.id = config.id;
      autocompleteInput.name = config.name;
      config.element.appendChild(autocompleteInput);
    });

    initializeSearchAutocomplete(document.querySelector('#autocomplete'), {
      accessibleAutocomplete,
      debounce,
      fetchSuggestions,
    });
  });

  it.each([
    ['longer', 'tahini', 'tahini paste'],
    ['shorter', 'tahini paste', 'salt'],
    ['equal-length', 'tahini', 'tomato'],
  ])('submits a %s replacement query instead of an older suggestion', (
      _description,
      suggestion,
      latestQuery,
  ) => {
    requestSuggestions(suggestion, [suggestion]);
    typeQuery(latestQuery);
    autocompleteConfig.onConfirm(suggestion);

    expect(new FormData(form).get('q')).toBe(latestQuery);
    expect(form.submit).toHaveBeenCalled();
  });

  it('submits a suggestion confirmed for the current query', () => {
    typeQuery('tahini');
    requestSuggestions('tahini', ['tahini paste']);

    autocompleteConfig.onConfirm('tahini paste');

    expect(new FormData(form).get('q')).toBe('tahini paste');
  });

  it('submits an explicitly clicked suggestion from an older result set', () => {
    requestSuggestions('tahini', ['tahini']);
    typeQuery('tahini paste');
    const option = document.createElement('div');
    option.setAttribute('role', 'option');
    document.querySelector('#autocomplete').appendChild(option);

    option.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    autocompleteConfig.onConfirm('tahini');

    expect(new FormData(form).get('q')).toBe('tahini');
  });

  it('submits an explicitly keyboard-selected suggestion', () => {
    typeQuery('tahini');
    requestSuggestions('tahini', ['tahini paste']);

    autocompleteInput.dispatchEvent(new KeyboardEvent('keydown', {
      key: 'ArrowDown',
      bubbles: true,
    }));
    autocompleteConfig.onConfirm('tahini paste');

    expect(new FormData(form).get('q')).toBe('tahini paste');
  });

  it('captures the current value when the user tabs away from the input', () => {
    typeQuery('tahini');
    autocompleteInput.value = 'tahini paste';

    autocompleteInput.dispatchEvent(new KeyboardEvent('keydown', {
      key: 'Tab',
      bubbles: true,
    }));
    autocompleteInput.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    form.dispatchEvent(new Event('submit'));

    expect(new FormData(form).get('q')).toBe('tahini paste');
  });

  it('captures a direct value update immediately before submission', () => {
    typeQuery('tahini');
    autocompleteInput.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    autocompleteInput.value = 'voice entered query';

    form.dispatchEvent(new Event('submit'));

    expect(new FormData(form).get('q')).toBe('voice entered query');
  });

  it('preserves the typed query when autocomplete changes its controlled value after blur', async () => {
    typeQuery('tahini paste');
    autocompleteInput.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    autocompleteInput.value = 'tahini';
    await Promise.resolve();
    await Promise.resolve();

    form.dispatchEvent(new Event('submit'));

    expect(new FormData(form).get('q')).toBe('tahini paste');
  });

  it('clears visible and submitted queries when restoring a persisted page', () => {
    typeQuery('tahini');

    window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: true }));

    expect(autocompleteInput.value).toBe('');
    expect(new FormData(form).get('q')).toBe('');
  });

  it('uses the configured suggestions path', () => {
    autocompleteConfig.source('tomato', jest.fn());

    expect(fetchSuggestions).toHaveBeenCalledWith(
        'tomato',
        '/search_suggestions.json',
        [],
        expect.any(Function),
    );
  });

  it('uses debounce v3 options for suggestion requests', () => {
    expect(debounce).toHaveBeenCalledWith(
        expect.any(Function),
        200,
        { immediate: false },
    );
  });
});

describe('initializeSearchAutocompletes', () => {
  it('renders a plain input when autocomplete initialisation fails', () => {
    document.body.innerHTML = `
      <form>
        <div
          data-module="search-autocomplete"
          data-input-id="search-q-field"
          data-input-name="q"
        ></div>
      </form>
    `;

    initializeSearchAutocompletes(document, {
      accessibleAutocomplete: () => { throw new Error('initialisation failed'); },
      debounce: jest.fn(),
      fetchSuggestions: jest.fn(),
    });

    const fallback = document.querySelector('#search-q-field');
    expect(fallback.name).toBe('q');
    expect(fallback.required).toBe(true);
    expect(fallback.getAttribute('role')).toBeNull();
  });
});
