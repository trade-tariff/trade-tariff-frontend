import {Controller} from '@hotwired/stimulus';

import accessibleAutocomplete from 'accessible-autocomplete';
import Utility from 'utility';

export default class extends Controller {
  static targets = ['countrySelect'];

  clearSelect(event) {
    event.currentTarget.value = '';
  }

  connect() {
    this.selectElement = this.countrySelectTarget.querySelector('select');

    this.#initializeAutocomplete(this.selectElement);

    // Attach event listener after initialization as accessibleAutocomplete.enhanceSelectElement
    // hides focus event from stimulus.
    this.#attachFocusListener();
  }

  disconnect() {
    const autocompleteInput = this.countrySelectTarget.querySelector('input.autocomplete__input');
    if (autocompleteInput) {
      autocompleteInput.removeEventListener('focus', this.clearSelect.bind(this));
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

  #attachFocusListener() {
    // ensures focus event is attached to the accessible autocomplete.
    const autocompleteInput = this.countrySelectTarget.querySelector('input.autocomplete__input');

    if (autocompleteInput) {
      autocompleteInput.addEventListener('focus', this.clearSelect.bind(this));
    } else {
      console.error('Autocomplete input element not found.');
    }
  }
}
