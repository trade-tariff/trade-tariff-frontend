import accessibleAutocomplete from 'accessible-autocomplete';

(function(){
  var fieldset = $('.js-quota-country-picker');
  var autocomplete = null;

  $('.js-quota-country-picker-select').each(function() {
    (function(element) {
      autocomplete = accessibleAutocomplete.enhanceSelectElement({
        selectElement: element[0],
        minLength: 2,
        showAllValues: true,
        confirmOnBlur: true,
        dropdownArrow: function() {
          return "<span class='autocomplete__arrow'></span>";
        },
      });

      $('#' + element[0].id.replace('-select', '')).on('focus', function(event) {
        $(event.currentTarget).val('')
      });

    })($(this));
  });

  fieldset.on('click', 'a.reset-country-picker', function (e) {
    $('.js-quota-country-picker-select').val('');
    $('.js-quota-country-picker-select').trigger('blur');
    $('#' + $('.js-quota-country-picker-select').attr('name')).val('All Countries');

    return false;
  });
  $('form.quota-search#new_search').on("submit", function(){
    $(this).find(':input[type=submit]').prop('disabled', true);
  });
})();
