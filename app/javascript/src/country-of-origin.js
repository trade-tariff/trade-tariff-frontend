document.addEventListener('DOMContentLoaded', function () {
  var target = document.querySelector('[id^="duty-calculator-steps-country-of-origin-country-of-origin-field"]')
  if (target != undefined) {
    window.GOVUK.accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: document.querySelector('[id^="duty-calculator-steps-country-of-origin-country-of-origin-field"]'),
    })
  }
});
