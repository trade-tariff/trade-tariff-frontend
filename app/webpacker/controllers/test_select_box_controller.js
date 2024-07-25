import { Controller } from '@hotwired/stimulus';
import accessibleAutocomplete from 'accessible-autocomplete';

export default class extends Controller {
  static targets = ['testInput'];

  connect() {
    console.log('Stimulus controller connected');
    this.inputElement = this.testInputTarget.querySelector('input');
    this.autocomplete_input_id = this.inputElement.dataset.autocompleteInputId || 'q';
    console.log('Autocomplete input id:', this.autocomplete_input_id);
    this.#initializeAutocomplete();
  }

  #initializeAutocomplete() {
    console.log('Initializing autocomplete');

    accessibleAutocomplete({
      element: this.inputElement,
      id: this.autocomplete_input_id,
      minLength: 2,
      showAllValues: true, // Show all values for testing purposes
      confirmOnBlur: false,
      displayMenu: 'overlay',
      placeholder: 'Enter the name of the goods or commodity code',
      templates: {
        inputValue: (result) => {
          console.log('inputValueTemplate called:', result);
          return result || '';
        },
        suggestion: (result) => {
          console.log('suggestionTemplate called:', result);
          return result || '';
        }
      },
      source: (query, populateResults) => {
        console.log('Source function called with query:', query);
        const staticResults = ['result1', 'result2', 'result3', query];
        populateResults(staticResults);
      },
      onConfirm: (text) => {
        console.log('onConfirm called with text:', text);
      }
    });

    // Manually set the placeholder after initialization
    setTimeout(() => {
      const autocompleteInput = document.querySelector(`#${this.autocomplete_input_id}`);
      if (autocompleteInput) {
        autocompleteInput.setAttribute('placeholder', 'Enter the name of the goods or commodity code');
      }
    }, 500); // Delay to ensure the input is available
  }
}
