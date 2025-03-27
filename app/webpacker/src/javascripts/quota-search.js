import accessibleAutocomplete from 'accessible-autocomplete';

(function(global) {
  const $ = global.jQuery;
  const fieldset = $('.js-quota-country-picker');

  $('.js-quota-country-picker-select').each((_, element) => {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: element,
      minLength: 2,
      showAllValues: true,
      confirmOnBlur: true,
      dropdownArrow: function() {
        return '<span class=\'autocomplete__arrow\'></span>';
      },
    });

    $('#' + element.id.replace('-select', '')).on('focus', (event) => {
      $(event.currentTarget).val('');
    });
  });

  fieldset.on('click', 'a.reset-country-picker', (e) => {
    $('.js-quota-country-picker-select').val('');
    $('.js-quota-country-picker-select').trigger('blur');
    $('#' + $('.js-quota-country-picker-select').attr('name')).val('All Countries');

    return false;
  });

  $('form.quota-search#new_search').on('submit', (event) => {
    $(event.currentTarget).find(':input[type=submit]').prop('disabled', true);
  });
})(window);
