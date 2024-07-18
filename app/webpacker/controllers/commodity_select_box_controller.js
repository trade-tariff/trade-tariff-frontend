import {Controller} from '@hotwired/stimulus';
import accessibleAutocomplete from 'accessible-autocomplete';
import debounce from '../src/javascripts/debounce';
import Utility from '../src/javascripts/utility';

export default class extends Controller {
  static targets = ['commodityInput', 'resourceIdHidden'];

  connect() {
    this.inputElement = this.commodityInputTarget;
    this.resourceIdHidden = this.resourceIdHiddenTarget;
    this.autocomplete_input_id = this.inputElement.id || 'q';
    this.options = [];
    this.searching = true;

    // Reset the input value on connection so it doesn't persist between pages
    this.inputElement.value = '';
    this.resourceIdHidden.value = '';

    this.#initializeAutocomplete();
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
      id: this.autocomplete_input_id,
      minLength: 2,
      showAllValues: false,
      confirmOnBlur: false,
      displayMenu: 'overlay',
      placeholder: 'Enter the name of the goods or commodity code',
      tNoResults: () => this.searching ? 'Searching...' : 'No results found',
      templates: {
        inputValue: this.inputValueTemplate.bind(this),
        suggestion: this.suggestionTemplate.bind(this),
      },
      source: debounce((query, populateResults) => {
        const searchSuggestionsPath = document.querySelector('.path_info').dataset.searchSuggestionsPath;
        Utility.fetchCommoditySearchSuggestions(query, searchSuggestionsPath, this.options, populateResults);
      }, 400, false),
      onConfirm: (text) => {
        Utility.commoditySelectorOnConfirm(text, this.options, this.resourceIdHidden, this.inputElement);
      },
    });
  }
}
