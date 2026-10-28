/* eslint-env node, jest */

import Cookies from 'js-cookie';

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

  it('submits the selected resource ID when labels match', () => {
    const suggestions = [
      { text: 'horses', resource_id: '12345' },
      { text: 'horses', resource_id: '67890' },
    ];
    typeQuery('horses');
    requestSuggestions('horses', suggestions);
    autocompleteInput.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));

    autocompleteConfig.onConfirm(suggestions[1]);

    expect(new FormData(form).get('q')).toBe('horses');
    expect(new FormData(form).get('resource_id')).toBe('67890');
    expect(form.submit).toHaveBeenCalled();
  });

  it.each(['submit', 'Tab', 'blur'])('clears a restored SID after a direct query edit and %s', (event) => {
    document.body.innerHTML = `
      <form>
        <input type="hidden" name="resource_id" value="67890">
        <input type="hidden" name="resource_id_query" value="Horses">
        <div id="autocomplete" data-input-id="restored-query" data-input-name="q" data-input-value="Horses"></div>
      </form>
      <div class="path_info" data-search-suggestions-path="/search_suggestions.json"></div>
    `;
    form = document.querySelector('form');
    form.submit = jest.fn();
    initializeSearchAutocomplete(document.querySelector('#autocomplete'), {
      accessibleAutocomplete: (config) => {
        autocompleteConfig = config;
        autocompleteInput = document.createElement('input');
        autocompleteInput.id = config.id;
        autocompleteInput.name = config.name;
        autocompleteInput.value = config.defaultValue;
        config.element.appendChild(autocompleteInput);
      },
      debounce,
      fetchSuggestions,
    });

    expect(new FormData(form).get('q')).toBe('Horses');
    expect(new FormData(form).get('resource_id')).toBe('67890');
    expect(form.querySelectorAll('input[name="resource_id"]')).toHaveLength(1);

    autocompleteInput.value = 'horse toys';
    if (event === 'Tab') autocompleteInput.dispatchEvent(new KeyboardEvent('keydown', { key: 'Tab', bubbles: true }));
    if (event !== 'submit') autocompleteInput.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    form.dispatchEvent(new Event('submit'));

    expect(new FormData(form).get('q')).toBe('horse toys');
    expect(new FormData(form).get('resource_id')).toBe('');

    const suggestion = { text: 'Horse toys', resource_id: '99999' };
    requestSuggestions('horse toys', [suggestion]);
    autocompleteConfig.onConfirm(suggestion);

    expect(new FormData(form).get('resource_id')).toBe('99999');
    expect(new FormData(form).get('resource_id_query')).toBe('Horse toys');
  });

  it.each([
    ['implicit keyboard confirmation', '67890'],
    ['explicit keyword selection', ''],
  ])('handles a restored SID on %s of an unchanged query', (confirmation, expectedId) => {
    document.body.innerHTML = `
      <form>
        <input type="hidden" name="resource_id" value="67890">
        <input type="hidden" name="resource_id_query" value="Horses">
        <div id="autocomplete" data-input-id="restored-query" data-input-name="q" data-input-value="Horses"></div>
      </form>
      <div class="path_info" data-search-suggestions-path="/search_suggestions.json"></div>
    `;
    form = document.querySelector('form');
    form.submit = jest.fn();
    initializeSearchAutocomplete(document.querySelector('#autocomplete'), {
      accessibleAutocomplete: (config) => {
        autocompleteConfig = config;
        autocompleteInput = document.createElement('input');
        autocompleteInput.id = config.id;
        autocompleteInput.name = config.name;
        autocompleteInput.value = config.defaultValue;
        config.element.appendChild(autocompleteInput);
      },
      debounce,
      fetchSuggestions,
    });
    const keyword = { text: 'Horses' };
    requestSuggestions('Horses', [keyword, { text: 'Horses', resource_id: '12345' }]);
    if (confirmation === 'explicit keyword selection') {
      const option = document.createElement('div');
      option.setAttribute('role', 'option');
      document.querySelector('#autocomplete').appendChild(option);
      option.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    } else {
      autocompleteInput.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }));
    }
    autocompleteConfig.onConfirm(keyword);

    expect(new FormData(form).get('q')).toBe('Horses');
    expect(new FormData(form).get('resource_id')).toBe(expectedId);
    expect(form.submit).toHaveBeenCalled();
  });

  it('does not attach a stale suggestion ID to a new query', () => {
    const suggestion = { text: 'horses', resource_id: '12345' };
    requestSuggestions('horses', [suggestion]);
    typeQuery('horse toys');

    autocompleteConfig.onConfirm(suggestion);

    expect(new FormData(form).get('q')).toBe('horse toys');
    expect(new FormData(form).get('resource_id')).toBe('');
  });

  it('clears a selected resource ID after typing', () => {
    const suggestion = { text: 'horses', resource_id: '12345' };
    typeQuery('horses');
    requestSuggestions('horses', [suggestion]);
    autocompleteConfig.onConfirm(suggestion);

    typeQuery('horse toys');
    form.dispatchEvent(new Event('submit'));

    expect(new FormData(form).get('resource_id')).toBe('');
  });

  it('renders an empty input before a selection exists', () => {
    expect(autocompleteConfig.templates.inputValue(undefined)).toBe('');
    expect(autocompleteConfig.templates.inputValue(null)).toBe('');
  });

  it('renders object labels without unsafe markup', () => {
    const suggestion = { text: '<img src=x onerror=alert(1)> horses', resource_id: '12345' };
    requestSuggestions('horses', [suggestion]);

    const option = document.createElement('div');
    option.innerHTML = autocompleteConfig.templates.suggestion(suggestion);

    expect(autocompleteConfig.templates.inputValue(suggestion)).toBe(suggestion.text);
    expect(option.querySelector('img')).toBeNull();
    expect(option.querySelector('strong').textContent).toBe('horses');
    expect(option.textContent).toBe(suggestion.text);
  });

  it.each([
    ['am', null],
    ['&', '&'],
  ])('matches %s in the original label rather than escaped HTML', (query, highlighted) => {
    const suggestion = { text: 'LAMPS & LIGHTING', resource_id: '12345' };
    requestSuggestions(query, [suggestion]);

    const option = document.createElement('div');
    option.innerHTML = autocompleteConfig.templates.suggestion(suggestion);

    expect(option.textContent).toBe(suggestion.text);
    expect(option.querySelector('strong')?.textContent ?? null).toBe(highlighted);
  });

  it('publishes keyword context before programmatic submission', () => {
    Cookies.set('cookies_policy', JSON.stringify({ usage: true }));
    document.head.innerHTML = `<script type="application/json" id="search-analytics-context">${JSON.stringify({
      search_experience: 'guided_beta', search_mode: 'guided', search_state: 'results',
    })}</script>`;
    window.dataLayer = [];
    let submittedContext;
    form.submit.mockImplementation(() => { submittedContext = window.dataLayer.at(-1); });

    autocompleteConfig.onConfirm('tahini');

    expect(submittedContext).toMatchObject({
      search_experience: 'guided_beta', search_mode: 'keyword', search_state: 'submitted',
    });
    Cookies.remove('cookies_policy');
    delete window.dataLayer;
    document.head.innerHTML = '';
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
    requestSuggestions('tahini', [{ text: 'tahini', resource_id: '12345' }]);
    autocompleteConfig.onConfirm({ text: 'tahini', resource_id: '12345' });

    window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: true }));

    expect(autocompleteInput.value).toBe('');
    expect(new FormData(form).get('q')).toBe('');
    expect(new FormData(form).get('resource_id')).toBe('');
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
  it('marks the input as invalid, links the hint and error, and focuses it for an error state', () => {
    document.body.innerHTML = `
      <form>
        <div
          data-described-by="query-hint query-error"
          data-input-error="true"
          data-autofocus="true"
          data-input-value="GB123456789000"
          data-module="search-autocomplete"
          data-input-id="search-q-field"
          data-input-name="q"
        ></div>
      </form>
      <div class="path_info" data-search-suggestions-path="/search_suggestions.json"></div>
    `;
    let config;
    const keydowns = [];
    document.addEventListener('keydown', (event) => keydowns.push(event.keyCode));

    initializeSearchAutocompletes(document, {
      accessibleAutocomplete: (options) => {
        config = options;
        const input = document.createElement('input');
        input.id = options.id;
        input.setAttribute('aria-describedby', 'search-q-field__assistiveHint');
        options.element.appendChild(input);
      },
      debounce: jest.fn((callback) => callback),
      fetchSuggestions: jest.fn(),
    });

    const input = document.querySelector('#search-q-field');
    expect(config.inputClasses).toBe('govuk-input--error');
    expect(input.getAttribute('aria-describedby')).toBe('search-q-field__assistiveHint query-hint query-error');
    expect(document.activeElement).toBe(input);
    // Closes the menu that the autocomplete opens on focus, so Enter submits the form.
    expect(keydowns).toEqual([27]);
  });

  it('marks and focuses the plain input for an error state when autocomplete initialisation fails', () => {
    document.body.innerHTML = `
      <form>
        <div
          data-input-error="true"
          data-autofocus="true"
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
    expect(fallback.classList).toContain('govuk-input--error');
    expect(document.activeElement).toBe(fallback);
  });

  it('renders a plain input when autocomplete initialisation fails', () => {
    document.body.innerHTML = `
      <form>
        <input type="hidden" name="resource_id" value="67890">
        <div
          data-described-by="query-hint"
          data-input-value="coffee beans"
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
    expect(fallback.value).toBe('coffee beans');
    expect(fallback.getAttribute('aria-describedby')).toBe('query-hint');
    expect(fallback.getAttribute('role')).toBeNull();
    expect(new FormData(document.querySelector('form')).get('resource_id')).toBe('67890');

    fallback.value = 'coffee toys';
    fallback.dispatchEvent(new Event('input', { bubbles: true }));

    expect(new FormData(document.querySelector('form')).get('resource_id')).toBe('');
  });
});
