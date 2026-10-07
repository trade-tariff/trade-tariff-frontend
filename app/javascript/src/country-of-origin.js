document.addEventListener('DOMContentLoaded', function () {
  var target = document.querySelector('[id^="duty-calculator-steps-country-of-origin-country-of-origin-field"], [id^="duty-calculator-steps-import-details-country-of-origin-field"]')
  if (target != undefined) {
    window.GOVUK.accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: target,
    })
  }

  // Import details page: the country list follows the selected part of the UK,
  // as on the separate country of origin page.
  var container = document.getElementById('import-details-country')
  if (container == undefined || target == undefined) return

  var lists = JSON.parse(container.dataset.countryLists)
  var fieldId = target.id.replace(/-select$/, '')

  document.querySelectorAll('input[name="duty_calculator_steps_import_details[import_destination]"]').forEach(function (radio) {
    radio.addEventListener('change', function () {
      var select = document.getElementById(fieldId + '-select') || document.getElementById(fieldId)
      var current = select.value
      var options = lists[radio.value] || []

      select.innerHTML = ''
      select.appendChild(new Option('', ''))
      options.forEach(function (country) {
        select.appendChild(new Option(country[1], country[0], false, country[0] === current))
      })

      var wrapper = select.previousElementSibling
      if (wrapper != undefined && wrapper.querySelector('.autocomplete__wrapper')) wrapper.remove()
      select.id = fieldId
      select.style.display = ''
      window.GOVUK.accessibleAutocomplete.enhanceSelectElement({
        defaultValue: '',
        selectElement: select,
      })
    })
  })
});
