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

    this.#initializeAutocomplete();
    this.#attachEventListeners();
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

  #attachEventListeners() {
    this.inputElementForEventHandling = document.getElementById('q');
    this.inputElementForEventHandling.addEventListener('keydown', (event) => {
      if (event.target.matches('input[type="text"]')) {
        this.#handleSubmitEvent(event);
      }
    });

    // Selecting a list option is handled by accessibleAutocomplete onConfirm now
    // this.inputElementForEventHandling.addEventListener('keydown', (event) => {
    //   if (event.target.matches('li[id^="q__option--"]')) {
    //     this.#handleSubmitEvent(event);
    //   }
    // });

    // Clicking a list option is handled by accessibleAutocomplete onConfirm now
    // this.inputElementForEventHandling.addEventListener('click', (event) => {
    //   if (event.target.matches('li[id^="q__option--"]')) {
    //     this.#handleSubmitEvent(event);
    //   }
    // });
  }

  // Avoid the default keydown behaviour of the autocomplete library and
  // auto submit on Mousclick, Enter or Tab ourselves
  // when an element receives Enter, the form is submitted
  // when an element selected with arrow keys, the form is not submitted
  #handleSubmitEvent(event) {
    // NOT SURE IF THE COMMENTED OUT CODE BELOW IS REQUIRED
    // FOR EXAMPLE THE SEARCH FOR 'TEA' AND HITTING ENTER HAS THE SAME EFFECT AS CLICKING ON IT IN THE DROPDOWN.
    // CLICK is handled by onConfirm in accessibleAutocomplete now.
    if (event.key === 'Enter' || event.key === 'Tab') {
      this.inputElement.value = event.target.value;
      const text = event.target.value;
      Utility.commoditySelectorOnConfirm(text, this.options, this.resourceIdHidden, this.inputElement);

      //   const form = $(element).parents('form');
      //   const suggestionType = $(ev.target).find('[data-suggestion-type]').data('suggestion-type');
      //   const resourceId = $(ev.target).find('[data-resource-id]').data('resource-id');
      //   let text = $(ev.target).text();

      //   ev.preventDefault();

      //   if (text === '') {
      //     text = $(element).find('input[type="text"]').val();
      //   }

      //   if (suggestionType) {
      //     text = text.replace(suggestionType, '');
      //   }

      //   // accessible-autocomplete adds the index of the options into
      //   // the option text on ios for some reason
      //   // That breaks search so strip it back out
      //   // FIXME: Solve event handling so we can just handle submission
      //   // in onConfirm and avoid all this complexity
      //   if (isIosDevice()) {
      //     text = text.replace(/ \d+ of \d+$/, '');
      //   }

      //   form.find('.js-commodity-picker-target').val(text);

      //   if (resourceId) {
      //     form.find('.js-commodity-picker-resource-id').val(resourceId);
      //   }

    //   form.submit();
    }
  }
}
