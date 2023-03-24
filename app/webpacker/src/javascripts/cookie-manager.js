import Cookies from 'js-cookie';

export default class CookieManager {
  constructor() {
    this.cookiesPolicyName = 'cookies_policy';
    this.cookiesHideConfirmName = 'cookies_preferences_set';
    this.expiresInOneYear = 365;
  }

  rememberSettings() {
    if (this.getCookiesPolicy()) {
      const rememberSettings = this.getCookiesPolicy().remember_settings;

      if (rememberSettings === 'true') {
        return true;
      } else if (rememberSettings === 'false') {
        return false;
      } else {
        return rememberSettings;
      }
    } else {
      return false;
    }
  }

  usage() {
    if (this.getCookiesPolicy()) {
      const usage = this.getCookiesPolicy().usage;

      if (usage === 'true') {
        return true;
      } else if (usage === 'false') {
        return false;
      } else {
        return usage;
      }
    } else {
      return false;
    }
  }

  showAcceptRejectCookiesBanner() {
    if (!this.getCookiesPolicy()) {
      return true;
    } else {
      return false;
    }
  }

  showHideConfirmCookiesBanner() {
    if (this.getCookiesHideConfirm() === null) {
      return true;
    } else {
      return false;
    }
  }

  setCookiesPolicy(value = {usage: true, remember_settings: true}) {
    this.#setCookie(this.cookiesPolicyName, value, this.expiresInOneYear);
  }

  getCookiesPolicy() {
    return this.#getCookie(this.cookiesPolicyName);
  }

  setCookiesHideConfirm(value = {value: true}) {
    this.#setCookie(this.cookiesHideConfirmName, value, this.expiresInOneYear);
  }

  getCookiesHideConfirm() {
    return this.#getCookie(this.cookiesHideConfirmName);
  }

  #setCookie(name, value, expires) {
    const isSecureEnvironment = location.protocol === 'https:';
    const encodedValue = JSON.stringify(value);
    Cookies.set(name, encodedValue, {expires: expires, secure: isSecureEnvironment});
  }

  #getCookie(name) {
    const candidateJson = Cookies.get(name);

    if (!candidateJson) {
      return null;
    }

    try {
      return JSON.parse(candidateJson);
    } catch (e) {
      return candidateJson;
    }
  }
}
