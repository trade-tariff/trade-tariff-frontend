export default class Utility {
    static countrySelectorOnConfirm(confirmed, selectElement) {
      const commodityCode = document.querySelector('.commodity-header').dataset.commCode;

      if (confirmed === 'All countries') {
        const selectedTab = window.location.hash.substring(1);
        const url = `/commodities/${commodityCode}#${selectedTab}`;
        window.location.href = url;
      } else {
        const code = /\((\w\w)\)/.test(confirmed) ? /\((\w\w)\)/.exec(confirmed)[1] : null;
        selectElement.value = code;
        const anchorInput = selectElement.closest('.govuk-fieldset').querySelector('input[name$="[anchor]"]');
        console.log('anchorInput: ' + anchorInput);
        anchorInput.value = window.location.hash.substring(1);
        selectElement.closest('form').submit();
      }
    }
  }
