import {Controller} from '@hotwired/stimulus';
const CookieManager = require('../src/javascripts/cookie-manager.js').default;

export default class extends Controller {
  static targets = [
    'successMessage',
    'usageRadioTrue',
    'usageRadioFalse',
    'rememberSettingsRadioTrue',
    'rememberSettingsRadioFalse',
  ];

  connect() {
    this.cookieManager = new CookieManager();

    if (this.cookieManager.getCookiesPolicy()) {
      this.#updatePolicyBasedOnCookies();
    }
  }

  updatePolicy(event) {
    event.preventDefault();

    if (this.#pickedAllOptions()) {
      this.cookieManager.setCookiesPolicy({
        usage: this.#usage(),
        remember_settings: this.#rememberSettings(),
      });
      this.#showSuccessMessage();
    }
  }


  #updatePolicyBasedOnCookies() {
    if (this.#hasRadioTargets) {
      this.#updateUsage();
      this.#updateRememberSettings();
    }
  }

  #usage() {
    if (this.usageRadioTrueTarget.checked) {
      return true;
    } else if (this.usageRadioFalseTarget.checked) {
      return false;
    }
  }

  #rememberSettings() {
    if (this.rememberSettingsRadioTrueTarget.checked) {
      return true;
    } else if (this.rememberSettingsRadioFalseTarget.checked) {
      return false;
    }
  }

  #updateUsage() {
    if (this.cookieManager.usage()) {
      this.usageRadioTrueTarget.checked = true;
    } else {
      this.usageRadioFalseTarget.checked = true;
    }
  }

  #updateRememberSettings() {
    if (this.cookieManager.rememberSettings()) {
      this.rememberSettingsRadioTrueTarget.checked = true;
    } else {
      this.rememberSettingsRadioFalseTarget.checked = true;
    }
  }

  #showSuccessMessage() {
    this.successMessageTarget.hidden = false;
    this.successMessageTarget.scrollIntoView({behavior: 'smooth', block: 'center'});
  }

  #hasRadioTargets() {
    const hasTargets = this.hasUsageRadioTrueTarget &&
      this.hasUsageRadioFalseTarget &&
      this.hasRememberSettingsRadioTrueTarget &&
      this.hasRememberSettingsRadioFalseTarget;

    return hasTargets;
  }

  #pickedAllOptions() {
    const pickedAllOptions = this.#pickedUsageOption() && this.#pickedRememberSettingsOption;

    return pickedAllOptions;
  }

  #pickedUsageOption() {
    const pickedUsageOption = this.usageRadioTrueTarget.checked || this.usageRadioFalseTarget.checked;

    return pickedUsageOption;
  }

  #pickedRememberSettingsOption() {
    const pickedRememberSettingsOption = this.rememberSettingsRadioTrueTarget.checked || this.rememberSettingsRadioFalseTarget.checked;

    return pickedRememberSettingsOption;
  }
}
