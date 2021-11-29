import accessibleAutocomplete from 'accessible-autocomplete';

export default class CountryAutocomplete {
  enhanceElement(element) {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: element
    });
  }
}
