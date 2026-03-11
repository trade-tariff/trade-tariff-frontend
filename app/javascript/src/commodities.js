document.addEventListener('DOMContentLoaded', () => {
  const copyCodeButton = $('#copy_code');
  const copyCodeLabel = copyCodeButton.find('.commodity-action-button__copy-label');
  const defaultCopyCodeLabel = copyCodeLabel.text();
  const copiedCopyCodeLabel = copyCodeButton.data('copied-label');
  let resetLabelTimeout;

  copyCodeButton.on('click', function(event) {
    navigator.clipboard.writeText($(this).attr('comm-code'));
    copyCodeLabel.text(copiedCopyCodeLabel);
    copyCodeButton.addClass('commodity-action-button--copied');
    clearTimeout(resetLabelTimeout);
    resetLabelTimeout = setTimeout(() => {
      copyCodeLabel.text(defaultCopyCodeLabel);
    }, 5000);
    event.preventDefault();
  });
});
