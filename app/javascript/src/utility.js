export default class Utility {
  static countrySelectorOnConfirm(confirmed, selectElement) {
    const selectedOption = [...selectElement.options].find((option) => option.text === confirmed);

    if (selectedOption) {
      selectElement.value = selectedOption.value;
      selectElement.dispatchEvent(new Event('change', {bubbles: true}));
    }
  }

  static async fetchCommoditySearchSuggestions(query, searchSuggestionsPath, options, populateResults) {
    const fetchURL = new URL(window.location.href);
    fetchURL.pathname = searchSuggestionsPath;
    fetchURL.searchParams.append('term', query);

    try {
      const response = await fetch(fetchURL, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data = await response.json();
      // Public V2 IDs identify suggestion rows, not search destinations.
      const results = data.results.map((result) => data.use_resource_ids ? result : { text: result.text });
      const hasKeywordOption = results.some((result) => result.text === query && !result.resource_id);
      const newSource = hasKeywordOption ? results : [{ text: query }, ...results];

      populateResults(newSource);
      document.dispatchEvent(new CustomEvent('tariff:searchQuery', {detail: [data, {'term': query}]}));
    } catch (error) {
      console.error('Error fetching data:', error);
      populateResults([]);
    }
  }

  static commoditySelectorOnConfirm(text, options, resourceIdHidden, inputElement) {
    let selectedOption = null;
    options.forEach((option) => {
      if (option.text === text.id || option.text === text) {
        selectedOption = option;
      }
    });
    if (selectedOption) {
      resourceIdHidden.value = selectedOption.resource_id;
      inputElement.value = decodeURIComponent(selectedOption.id);
      const form = inputElement.closest('form');
      form.submit();
    }
  }
}
