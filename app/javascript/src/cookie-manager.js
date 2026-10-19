import Cookies from 'js-cookie';

export default class CookieManager {
  constructor() {
    this.cookiesPolicyName = 'cookies_policy';
    this.cookiesHideConfirmName = 'cookies_preferences_set';
    this.cookiesTreeOpenClosedDefault = 'tree_open_close_default';
    this.commodityHierarchyOpenName = 'commodity_hierarchy_open';
    this.commoditySearchOpenName = 'commodity_search_open';
    this.expiresInOneYear = 365;
    this.expiresInTwentyEightDays = 28;
  }

  rememberSettings() {
    const rememberSettings = this.getCookiesPolicy()?.remember_settings;
    return rememberSettings === true || rememberSettings === 'true';
  }

  usage() {
    const usage = this.getCookiesPolicy()?.usage;
    return usage === true || usage === 'true';
  }

  shouldOpenTree() {
    if (this.getCookiesTreeOpenClosedDefault()) {
      const value = this.getCookiesTreeOpenClosedDefault();

      if (value === 'open') {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
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

    if (value && (value.remember_settings === false || value.remember_settings === 'false')) {
      this.clearCommodityHierarchyOpen();
      this.clearCommoditySearchOpen();
    }
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

  setCookiesTreeOpenClosedDefault(value = {value: 'open'}) {
    this.#setCookie(this.cookiesTreeOpenClosedDefault, value, this.expiresInTwentyEightDays);
  }

  getCookiesTreeOpenClosedDefault() {
    const cookie = this.#getCookie(this.cookiesTreeOpenClosedDefault);
    if (cookie) {
      return cookie.value;
    } else {
      return 'open';
    }
  }

  setCommodityHierarchyOpen(value) {
    this.#setCookie(this.commodityHierarchyOpenName, {value}, this.expiresInTwentyEightDays);
  }

  getCommodityHierarchyOpen() {
    const cookie = this.#getCookie(this.commodityHierarchyOpenName);
    if (!cookie || (cookie.value !== 'open' && cookie.value !== 'closed')) {
      return null;
    }

    return cookie.value;
  }

  clearCommodityHierarchyOpen() {
    if (Cookies.get(this.commodityHierarchyOpenName) === undefined) return;

    Cookies.remove(this.commodityHierarchyOpenName);
  }

  setCommoditySearchOpen(value) {
    this.#setCookie(this.commoditySearchOpenName, {value}, this.expiresInTwentyEightDays);
  }

  getCommoditySearchOpen() {
    const cookie = this.#getCookie(this.commoditySearchOpenName);
    if (!cookie || (cookie.value !== 'open' && cookie.value !== 'closed')) {
      return null;
    }

    return cookie.value;
  }

  clearCommoditySearchOpen() {
    if (Cookies.get(this.commoditySearchOpenName) === undefined) return;

    Cookies.remove(this.commoditySearchOpenName);
  }

  #setCookie(name, value, expires) {
    const isSecureEnvironment = location.protocol === 'https:';
    const encodedValue = JSON.stringify(value);

    Cookies.set(name, encodedValue, {
      expires: expires,
      secure: isSecureEnvironment,
      sameSite: 'Strict',
    });
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
