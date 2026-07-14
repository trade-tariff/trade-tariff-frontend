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
  let autocompleteInput;
  let tempQuery = '';
  let latestTypedQuery = '';
  let lastInputEventQuery = '';
  let populatedSuggestionsQuery = '';
  let explicitSuggestionSelection = false;
  let queryCapturedBeforeBlur = false;
  let controlledValueAfterBlur = null;

  submittedQueryInput.type = 'hidden';
  submittedQueryInput.name = inputName;
  submittedQueryInput.id = `${inputId}-submitted-query`;
  autocompleteElement.appendChild(submittedQueryInput);

  const syncSubmittedQuery = () => {
    if (autocompleteInput) {
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
    className: 'govuk-input',
    placeholder: 'Enter the name of the goods or commodity code',
    confirmOnBlur: false,
    autoselect: true,
    minLength: 2,
    tNoResults: () => 'Searching...',
    templates: {
      inputValue: (result) => result,
      suggestion: (result) => result.replace(tempQuery, '<strong>$&</strong>'),
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

        if (explicitSuggestionSelection || latestTypedQuery === populatedSuggestionsQuery) {
          autocompleteInput.value = suggestion;
          latestTypedQuery = suggestion;
        }

        explicitSuggestionSelection = false;
        submittedQueryInput.value = latestTypedQuery;
        form.submit();
      }
    },
  });

  autocompleteInput = document.getElementById(inputId);
  autocompleteInput.addEventListener('input', () => {
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
    }
  });
}

function renderFallbackInput(autocompleteElement) {
  const wrapper = document.createElement('div');
  const input = document.createElement('input');

  wrapper.className = 'autocomplete__wrapper';
  input.autocomplete = 'off';
  input.className = 'autocomplete__input autocomplete__input--default';
  input.id = autocompleteElement.dataset.inputId;
  input.name = autocompleteElement.dataset.inputName;
  input.placeholder = 'Enter the name of the goods or commodity code';
  input.type = 'text';
  input.required = true;
  wrapper.appendChild(input);
  autocompleteElement.replaceChildren(wrapper);
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
