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
      const results = data.results;
      const newSource = [];

      results.forEach((result) => {
        newSource.push(result.text);
      });

      if (!newSource.includes(query)) {
        newSource.unshift(query);
      }

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
