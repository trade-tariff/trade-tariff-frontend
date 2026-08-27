import {Controller} from '@hotwired/stimulus';

import accessibleAutocomplete from 'accessible-autocomplete';
import Utility from 'utility';

export default class extends Controller {
  static targets = ['countrySelect'];

  reopenSelect(event) {
    const selectedOption = this.selectElement.options[this.selectElement.selectedIndex];

    if (selectedOption && event.currentTarget.value === selectedOption.text) {
      event.currentTarget.value = '';
    }
  }

  connect() {
    this.selectElement = this.countrySelectTarget.querySelector('select');
    this.reopenSelectHandler = this.reopenSelect.bind(this);

    this.#initializeAutocomplete(this.selectElement);
    this.#attachReopenListener();
  }

  disconnect() {
    const autocompleteInput = this.countrySelectTarget.querySelector('input.autocomplete__input');
    if (autocompleteInput) {
      autocompleteInput.removeEventListener('click', this.reopenSelectHandler, true);
    }
  }

  #initializeAutocomplete(element) {
    const previousValue = this.#getPreviousValue();

    function matcher(query, element) {
      const options = [...element.options].map((o) => o.text);
      const filteredResults = options.filter((result) => normalizeString(result).indexOf(normalizeString(query)) !== -1);
      return filteredResults;
    }

    function normalizeString(str) {
      return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
    }


    accessibleAutocomplete.enhanceSelectElement({
      selectElement: this.selectElement,
      minLength: 2,
      autoselect: false,
      showAllValues: true,
      confirmOnBlur: false,
      alwaysDisplayArrow: true,
      displayMenu: 'overlay',
      placeholder: previousValue,
      dropdownArrow: function() {
        return '<span class="autocomplete__arrow"></span>';
      },
      source: function(query, populateResults) {
        populateResults(matcher(query, element));
      },
      onConfirm: (confirmed) => Utility.countrySelectorOnConfirm(confirmed, this.selectElement),
    });
  }

  #getPreviousValue() {
    const selectedOption = this.selectElement ? this.selectElement.options[this.selectElement.selectedIndex] : null;
    return selectedOption ? selectedOption.textContent : '';
  }

  #attachReopenListener() {
    const autocompleteInput = this.countrySelectTarget.querySelector('input.autocomplete__input');

    if (autocompleteInput) {
      // Run before accessible-autocomplete's click handler so it sees an empty
      // query and opens the full list immediately.
      autocompleteInput.addEventListener('click', this.reopenSelectHandler, true);
    } else {
      console.error('Autocomplete input element not found.');
    }
  }
}
