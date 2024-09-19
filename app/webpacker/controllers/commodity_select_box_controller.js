import {Controller} from '@hotwired/stimulus';
import accessibleAutocomplete from 'accessible-autocomplete';
import debounce from '../src/javascripts/debounce';
import Utility from '../src/javascripts/utility';

export default class extends Controller {
  static targets = ['commodityInput', 'resourceIdHidden'];

  connect() {
    this.inputElement = this.commodityInputTarget;
    this.resourceIdHidden = this.resourceIdHiddenTarget;
    this.autocompleteInputId = this.inputElement.id || 'q';
    this.options = [];
    this.searching = true;

    // Reset the input value on connection so it doesn't persist between pages
    this.inputElement.value = '';
    this.resourceIdHidden.value = '';

    this.#setPlaceholder();
    this.#initializeAutocomplete();
    this.#attachEventListeners();
  }

  disconnect() {
    window.removeEventListener('resize', this.#setPlaceholder.bind(this));
  }

  // templates can't be private functions as they won't work with dynamic accessibleAutocomplete.enhanceSelectElement
  inputValueTemplate(result) {
    if (result && result.id) {
      return decodeURIComponent(result.id);
    } else {
      return decodeURIComponent(result);
    }
  }

  suggestionTemplate(result) {
    if (typeof result === 'string') {
      return decodeURIComponent(result);
    } else if (result && result.text && result.query) {
      let enhanced = result.text.replace(new RegExp(result.query, 'gi'), `<strong>$&</strong>`);

      if (result.formatted_suggestion_type) {
        enhanced = `<span data-resource-id="${result.resource_id}"
                    data-suggestion-type="${result.formatted_suggestion_type}">${enhanced}</span>`;
        enhanced += `<span class="suggestion-type">${result.formatted_suggestion_type}</span>`;
      }

      return decodeURIComponent(enhanced);
    }
  }

  #initializeAutocomplete() {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: this.inputElement,
      id: this.autocompleteInputId,
      minLength: 2,
      showAllValues: false,
      confirmOnBlur: false,
      displayMenu: 'overlay',
      placeholder: this.inputElement.getAttribute('placeholder'),
      tNoResults: () => this.searching ? 'Searching...' : 'No results found',
      templates: {
        inputValue: this.inputValueTemplate.bind(this),
        suggestion: this.suggestionTemplate.bind(this),
      },
      source: debounce((query, populateResults) => {
        const searchSuggestionsPath = document.querySelector('.path_info').dataset.searchSuggestionsPath;
        Utility.fetchCommoditySearchSuggestions(query, searchSuggestionsPath, this.options, populateResults);
      }, 200, false),
      onConfirm: (text) => {
        Utility.commoditySelectorOnConfirm(text, this.options, this.resourceIdHidden, this.inputElement);
      },
    });
  }

  #attachEventListeners() {
    this.inputElementForEventHandling = document.getElementById('q');
    this.inputElementForEventHandling.addEventListener('keydown', (event) => {
      if (event.target.matches('input[type="text"]')) {
        this.#handleSubmitEvent(event);
      }
    });

    // handle submit button event
    const formElement = this.inputElement.closest('form');
    formElement.addEventListener('submit', (event) => {
      event.preventDefault();
      this.inputElement.value = this.inputElementForEventHandling.value;
      this.#handleSubmitEvent(event);
    });
  }

  #handleSubmitEvent(event) {
    // Event handling for when user doesn't wait for autocomplete and submits a search
    if (event.key) {
      if (event.key === 'Enter') {
        if (event.target.value) {
          this.inputElement.value = event.target.value;
          const text = event.target.value;
          Utility.commoditySelectorOnConfirm(text, this.options, this.resourceIdHidden, this.inputElement);
        }
      }
    } else {
      // no key event so submit the form anyway
      const form = this.inputElement.closest('form');
      form.submit();
    }
  }

  #setPlaceholder() {
    const placeholderText = window.matchMedia('(max-width: 440px)').matches ?
      'Name of goods or comm code' :
      'Enter the name of the goods or commodity code';
    this.inputElement.setAttribute('placeholder', placeholderText);
  }
}
