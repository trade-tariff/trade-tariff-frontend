document.addEventListener('DOMContentLoaded', function () {
  var target = document.querySelector('[id^="trading-partner-country-field"]')
  if (target != undefined) { 
    window.GOVUK.accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: document.querySelector('[id^="trading-partner-country-field"]'),
    })
  }
}); 
