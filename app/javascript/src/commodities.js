document.addEventListener('DOMContentLoaded', () => {
  $('#copy_comm_code').on('click', function(event) {
    navigator.clipboard.writeText($(this).attr('comm-code'));
    $('.copied').css('text-indent', '0');
          $('.copied')
            .delay(500)
            .fadeOut(750, function() {
              $('.copied').css('text-indent', '-999em');
              $('.copied').css('display', 'block');
            });
    event.preventDefault();
  });
});
