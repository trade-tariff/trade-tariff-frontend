export default class Utility {
  static countrySelectorOnConfirm(confirmed, selectElement) {
    const commodityCode = document.querySelector('.commodity-header').dataset.commCode;
    const service = document.getElementById('trading_partner_service').value;

    if (confirmed === 'All countries') {
      const selectedTab = window.location.hash.substring(1);
      if (service === 'xi') {
        const url = `${window.location.origin}/${service}/commodities/${commodityCode}#${selectedTab}`;
        window.location.href = url;
      } else {
        const url = `/commodities/${commodityCode}#${selectedTab}`;
        window.location.href = url;
      }
    } else {
      const code = /\((\w\w)\)/.test(confirmed) ? /\((\w\w)\)/.exec(confirmed)[1] : null;
      selectElement.value = code;
      const anchorInput = selectElement.closest('.govuk-fieldset').querySelector('input[name$="[anchor]"]');
      anchorInput.value = window.location.hash.substring(1);
      selectElement.closest('form').submit();
    }
  }

  static async fetchCommoditySearchSuggestions(query, searchSuggestionsPath, options, populateResults) {
    const escapedQuery = encodeURIComponent(query);
    const opts = {
      term: escapedQuery,
    };
    const queryParams = new URLSearchParams(opts).toString();

    try {
      const response = await fetch(`${searchSuggestionsPath}?${queryParams}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data = await response.json();
      const results = data.results;
      const newSource = [];
      options.length = 0;

      results.forEach((result) => {
        newSource.push(result);
        options.push(result);
      });

      if (!newSource.includes(escapedQuery.toLowerCase())) {
        newSource.unshift(escapedQuery.toLowerCase());
        options.unshift({
          id: escapedQuery.toLowerCase(),
          text: escapedQuery.toLowerCase(),
          suggestion_type: 'exact',
          newOption: true,
        });
      }
      populateResults(newSource);
      document.dispatchEvent(new CustomEvent('tariff:searchQuery', {detail: [data, opts]}));
    } catch (error) {
      console.error('Error fetching data:', error);
      populateResults([]);
    }
  }

  static commoditySelectorOnConfirm(text, options, resourceIdHidden, inputElement) {
    let selectedOption = null;
    console.log(options);
    options.forEach((option) => {
      if (option.text === text.id || option.text === text) {
        selectedOption = option;
      }
    });
    console.log('submitting form');
    console.log('resourceIdHidden.value: ', resourceIdHidden.value);
    console.log('inputElement.value: ', inputElement.value);
    if (selectedOption) {
      resourceIdHidden.value = selectedOption.resource_id;
      inputElement.value = decodeURIComponent(selectedOption.id);
      const form = inputElement.closest('form');
      console.log('selected option found submitting form');
      console.log('selected option found resourceIdHidden: ', resourceIdHidden);
      console.log('selected option found inputElement.value: ', inputElement.value);
      form.submit();
    }
  }
}
