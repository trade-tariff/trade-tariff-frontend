export default class Utility {
  static countrySelectorOnConfirm(confirmed, selectElement) {
    const commodityCode = document.querySelector('.commodity-header').dataset.commCode;
    const service = document.getElementById('trading_partner_service').value;
    const service = document.getElementById('trading_partner_service').value;

    if (confirmed === 'All countries') {
      const selectedTab = window.location.hash.substring(1);
      if (service === 'xi') {
        // stops url defaulting to uk service on redirect
        const url = `${window.location.origin}/${service}/commodities/${commodityCode}#${selectedTab}`;
        window.location.href = url;
      }
      else {
        // we don't want the 'uk' service in the URL.
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
}
