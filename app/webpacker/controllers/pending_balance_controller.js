import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['balance'];

  static values = {
    url: String,
    loaded: Boolean,
  };

  connect() {
    if (this.withinPopup() && !this.loadedValue) {
      this.loadedValue = true;
      this.fetchPendingBalance();
    }
  }

  fetchPendingBalance() {
    const that = this;

    const request = new XMLHttpRequest();
    request.open('GET', this.urlValue, true);
    request.timeout = 10 * 1000;
    request.onreadystatechange = function() {
      if (request.readyState === XMLHttpRequest.DONE && request.status === 200) {
        const balance = JSON.parse(request.responseText);
        that.showBalance(balance);
      }
    };

    request.send();
  }

  showBalance(balance) {
    if (balance === undefined || balance === null) {
      return;
    }

    this.balanceTarget.innerHTML = this.formattedBalance(balance);
    this.showPendingRow();
  }

  formattedBalance(balance) {
    if (!Intl || !Intl.NumberFormat) {
      return balance;
    }

    const formatter = new Intl.NumberFormat('en', {
      minimumFractionDigits: 3,
      maximumFractionDigits: 3,
    });

    return formatter.format(balance);
  }

  showPendingRow() {
    this.element.classList.remove('hidden-pending-balance');
  }

  withinPopup() {
    return window.jQuery(this.element).parents('#popup').length > 0;
  }
}
