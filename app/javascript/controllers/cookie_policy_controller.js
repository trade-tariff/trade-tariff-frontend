import {Controller} from '@hotwired/stimulus';

import CookieManager from 'cookie-manager';

const USAGE = 'cookies_policy[usage]';
const REMEMBER_SETTINGS = 'cookies_policy[remember_settings]';

export default class extends Controller {
  static targets = [
    'successMessage',
  ];

  connect() {
    this.cookieManager = new CookieManager();

    if (this.cookieManager.getCookiesPolicy()) {
      this.#updatePolicyBasedOnCookies();
    }
  }

  updatePolicy(event) {
    event.preventDefault();

    if (!this.#anyOptionPicked()) return;

    this.cookieManager.setCookiesPolicy({
      usage: this.#selectedBoolean(USAGE),
      remember_settings: this.#selectedBoolean(REMEMBER_SETTINGS),
    });
    this.#showSuccessMessage();
  }


  #updatePolicyBasedOnCookies() {
    if (this.#hasRadioInputs()) {
      this.#setRadioSelection(USAGE, this.cookieManager.usage());
      this.#setRadioSelection(REMEMBER_SETTINGS, this.cookieManager.rememberSettings());
    }
  }

  #selectedBoolean(name) {
    return this.#selectedRadioValue(name) === 'true';
  }

  #setRadioSelection(name, checked) {
    const value = checked === true ? 'true' : 'false';
    this.#radioByValue(name, value).checked = true;
  }

  #showSuccessMessage() {
    this.successMessageTarget.hidden = false;
    this.successMessageTarget.scrollIntoView({behavior: 'smooth', block: 'center'});
  }

  #hasRadioInputs() {
    return Boolean(this.#radioByValue(USAGE, 'true')) &&
      Boolean(this.#radioByValue(USAGE, 'false')) &&
      Boolean(this.#radioByValue(REMEMBER_SETTINGS, 'true')) &&
      Boolean(this.#radioByValue(REMEMBER_SETTINGS, 'false'));
  }

  #anyOptionPicked() {
    return this.#selectedRadioValue(USAGE) !== undefined || this.#selectedRadioValue(REMEMBER_SETTINGS) !== undefined;
  }

  #radioByValue(name, value) {
    return this.element.querySelector(`input[name="${name}"][value="${value}"]`);
  }

  #selectedRadioValue(name) {
    return this.element.querySelector(`input[name="${name}"]:checked`)?.value;
  }
}
