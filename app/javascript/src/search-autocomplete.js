import { publishSearchContext } from 'search-analytics';

function suggestionText(suggestion) {
  return typeof suggestion === 'string' ? suggestion : suggestion?.text || '';
}

function escapeHTML(text) {
  const element = document.createElement('span');
  element.textContent = text;
  return element.innerHTML;
}

// An error state focuses the search box and centres it, so the error above it
// and the guidance below it are visible together.
function focusErrorInput(autocompleteElement, input) {
  if (autocompleteElement.dataset.autofocus !== 'true') return;

  input.focus({ preventScroll: true });
  // On focus the autocomplete opens a menu with the restored term as its only
  // option, and that menu takes Enter. Close it as Escape does; typing opens it again.
  const escape = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true });
  Object.defineProperty(escape, 'keyCode', { value: 27 });
  input.dispatchEvent(escape);
  input.scrollIntoView?.({ block: 'center' });
}

export function initializeSearchAutocomplete(autocompleteElement, dependencies) {
  const {
    accessibleAutocomplete,
    debounce,
    fetchSuggestions,
  } = dependencies;
  const form = autocompleteElement.closest('form');
  const inputId = autocompleteElement.dataset.inputId;
  const inputName = autocompleteElement.dataset.inputName;
  const searchSuggestionsPathElement = document.querySelector('.path_info');
  const submittedQueryInput = document.createElement('input');
  const resourceIdInput = form.querySelector('input[name="resource_id"]') || document.createElement('input');
  const restoredQueryInput = form.querySelector('input[name="resource_id_query"]');
  let autocompleteInput;
  let tempQuery = '';
  let latestTypedQuery = autocompleteElement.dataset.inputValue || '';
  let lastInputEventQuery = '';
  let populatedSuggestionsQuery = '';
  let explicitSuggestionSelection = false;
  let queryCapturedBeforeBlur = false;
  let controlledValueAfterBlur = null;

  submittedQueryInput.type = 'hidden';
  submittedQueryInput.name = inputName;
  submittedQueryInput.id = `${inputId}-submitted-query`;
  autocompleteElement.appendChild(submittedQueryInput);
  resourceIdInput.type = 'hidden';
  resourceIdInput.name = 'resource_id';
  if (!resourceIdInput.isConnected) autocompleteElement.appendChild(resourceIdInput);

  const syncSubmittedQuery = () => {
    if (autocompleteInput) {
      if (autocompleteInput.value !== latestTypedQuery) resourceIdInput.value = '';
      latestTypedQuery = autocompleteInput.value;
      submittedQueryInput.value = latestTypedQuery;
    }
  };

  const captureExplicitSuggestionSelection = (event) => {
    const selectedOption = event.target.closest('[role="option"]');
    if (selectedOption && autocompleteElement.contains(selectedOption)) {
      explicitSuggestionSelection = true;
    }
  };

  const captureSubmittedQueryBeforeBlur = (event) => {
    if (event.target === autocompleteInput) {
      syncSubmittedQuery();
      queryCapturedBeforeBlur = true;
      window.queueMicrotask(() => {
        window.queueMicrotask(() => {
          controlledValueAfterBlur = autocompleteInput.value;
        });
      });

      const nextOption = event.relatedTarget?.closest?.('[role="option"]');
      if (!nextOption || !autocompleteElement.contains(nextOption)) {
        explicitSuggestionSelection = false;
      }
    }
  };

  const syncSubmittedQueryOnSubmit = () => {
    const valueChangedAfterBlur = queryCapturedBeforeBlur && (
      controlledValueAfterBlur === null
        ? autocompleteInput.value !== lastInputEventQuery
        : autocompleteInput.value !== controlledValueAfterBlur
    );

    if (!queryCapturedBeforeBlur || valueChangedAfterBlur) {
      syncSubmittedQuery();
    } else {
      submittedQueryInput.value = latestTypedQuery;
    }
  };

  accessibleAutocomplete({
    element: autocompleteElement,
    id: inputId,
    name: `${inputId}-autocomplete`,
    required: 'true',
    defaultValue: autocompleteElement.dataset.inputValue || '',
    className: 'govuk-input',
    inputClasses: autocompleteElement.dataset.inputError === 'true' ? 'govuk-input--error' : null,
    placeholder: 'Enter the name of the goods or commodity code',
    confirmOnBlur: false,
    autoselect: true,
    minLength: 2,
    tNoResults: () => 'Searching...',
    templates: {
      inputValue: suggestionText,
      suggestion: (result) => {
        const text = suggestionText(result);
        const matchIndex = text.indexOf(tempQuery);
        if (!tempQuery || matchIndex === -1) return escapeHTML(text);

        const before = escapeHTML(text.slice(0, matchIndex));
        const match = escapeHTML(text.slice(matchIndex, matchIndex + tempQuery.length));
        const after = escapeHTML(text.slice(matchIndex + tempQuery.length));
        return `${before}<strong>${match}</strong>${after}`;
      },
    },
    source: debounce((query, populateResults) => {
      tempQuery = query;
      const searchSuggestionsPath = searchSuggestionsPathElement.dataset.searchSuggestionsPath;
      fetchSuggestions(query, searchSuggestionsPath, [], (results) => {
        populatedSuggestionsQuery = query;
        populateResults(results);
      });
    }, 200, { immediate: false }),
    onConfirm: (suggestion) => {
      if (suggestion) {
        syncSubmittedQuery();

        const confirmedQuery = suggestionText(suggestion);
        const preservedResourceId = !explicitSuggestionSelection && confirmedQuery === latestTypedQuery
          ? resourceIdInput.value : '';
        resourceIdInput.value = preservedResourceId;
        if (explicitSuggestionSelection || latestTypedQuery === populatedSuggestionsQuery) {
          autocompleteInput.value = confirmedQuery;
          latestTypedQuery = confirmedQuery;
          resourceIdInput.value = suggestion.resource_id || preservedResourceId;
          if (restoredQueryInput) restoredQueryInput.value = latestTypedQuery;
        }

        explicitSuggestionSelection = false;
        submittedQueryInput.value = latestTypedQuery;
        publishSearchContext(form);
        form.submit();
      }
    },
  });

  autocompleteInput = document.getElementById(inputId);
  const describedBy = autocompleteElement.dataset.describedBy;
  if (describedBy) {
    // describedBy can hold more than one id, such as a hint and an error message.
    const describedByIds = describedBy.split(/\s+/).filter(Boolean);
    const associateHint = () => {
      const ids = autocompleteInput.getAttribute('aria-describedby')?.split(/\s+/).filter(Boolean) || [];
      const missingIds = describedByIds.filter((id) => !ids.includes(id));
      if (missingIds.length) autocompleteInput.setAttribute('aria-describedby', [...ids, ...missingIds].join(' '));
    };
    associateHint();
    // The autocomplete removes its own assistive hint after typing.
    new MutationObserver(associateHint).observe(autocompleteInput, { attributes: true, attributeFilter: ['aria-describedby'] });
  }
  syncSubmittedQuery();
  focusErrorInput(autocompleteElement, autocompleteInput);
  autocompleteInput.addEventListener('input', () => {
    resourceIdInput.value = '';
    explicitSuggestionSelection = false;
    queryCapturedBeforeBlur = false;
    controlledValueAfterBlur = null;
    syncSubmittedQuery();
    lastInputEventQuery = latestTypedQuery;
  });
  autocompleteInput.addEventListener('focus', () => {
    queryCapturedBeforeBlur = false;
    controlledValueAfterBlur = null;
  });
  autocompleteInput.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      explicitSuggestionSelection = true;
    }

    if (event.key === 'Escape') {
      explicitSuggestionSelection = false;
    }

    if (event.key === 'Enter' || event.key === 'Tab') {
      syncSubmittedQuery();
    }
  });
  autocompleteElement.addEventListener('click', captureExplicitSuggestionSelection, true);
  form.addEventListener('blur', captureSubmittedQueryBeforeBlur, true);
  form.addEventListener('submit', syncSubmittedQueryOnSubmit);

  window.addEventListener('pageshow', (event) => {
    if (event.persisted) {
      autocompleteInput.value = '';
      latestTypedQuery = '';
      lastInputEventQuery = '';
      queryCapturedBeforeBlur = false;
      controlledValueAfterBlur = null;
      submittedQueryInput.value = '';
      resourceIdInput.value = '';
    }
  });
}

function renderFallbackInput(autocompleteElement) {
  const wrapper = document.createElement('div');
  const input = document.createElement('input');

  wrapper.className = 'autocomplete__wrapper';
  input.autocomplete = 'off';
  input.className = 'autocomplete__input autocomplete__input--default';
  if (autocompleteElement.dataset.inputError === 'true') input.classList.add('govuk-input--error');
  input.id = autocompleteElement.dataset.inputId;
  input.name = autocompleteElement.dataset.inputName;
  input.placeholder = 'Enter the name of the goods or commodity code';
  input.type = 'text';
  input.required = true;
  input.value = autocompleteElement.dataset.inputValue || '';
  if (autocompleteElement.dataset.describedBy) input.setAttribute('aria-describedby', autocompleteElement.dataset.describedBy);
  const resourceIdInput = autocompleteElement.closest('form')?.querySelector('input[name="resource_id"]');
  const clearStaleSelection = () => {
    if (resourceIdInput && input.value !== autocompleteElement.dataset.inputValue) resourceIdInput.value = '';
  };
  input.addEventListener('input', clearStaleSelection);
  input.addEventListener('change', clearStaleSelection);
  wrapper.appendChild(input);
  autocompleteElement.replaceChildren(wrapper);
  focusErrorInput(autocompleteElement, input);
}

export function initializeSearchAutocompletes(root, dependencies) {
  root.querySelectorAll('[data-module="search-autocomplete"]').forEach((element) => {
    try {
      initializeSearchAutocomplete(element, dependencies);
    } catch (_error) {
      renderFallbackInput(element);
    }
  });
}
