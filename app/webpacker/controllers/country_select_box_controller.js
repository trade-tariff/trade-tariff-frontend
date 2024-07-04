import {Controller} from '@hotwired/stimulus';
import accessibleAutocomplete from "accessible-autocomplete";
import Utility from '../src/javascripts/utility';

export default class extends Controller {
  static targets = ["countrySelect"];

  connect() {
    this.selectElement = this.countrySelectTarget.querySelector('select');

    this.#initializeAutocomplete();

    // Attach event listener after initialization as accessibleAutocomplete.enhanceSelectElement
    // hides focus event from stimulus.
    this.#attachFocusListener();
  }

  #initializeAutocomplete() {
    const previousValue = this.#getPreviousValue();

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
      onConfirm: (confirmed) => Utility.countrySelectorOnConfirm(confirmed, this.selectElement)
    });
  }

  clearSelect(event) {
    event.currentTarget.value = '';
  }

  #getPreviousValue() {
    const selectedOption = this.selectElement ? this.selectElement.options[this.selectElement.selectedIndex] : null;
    return selectedOption ? selectedOption.textContent : "";
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

  disconnect() {
    const autocompleteInput = this.countrySelectTarget.querySelector('input.autocomplete__input');
    if (autocompleteInput) {
      autocompleteInput.removeEventListener('focus', this.clearSelect.bind(this));
    }
  }
}
