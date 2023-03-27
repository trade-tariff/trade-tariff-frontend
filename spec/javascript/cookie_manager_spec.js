import CookieManager from 'cookie-manager';
import Cookies from 'js-cookie';

describe('CookieManager', () => {
  let cookieManager;

  beforeEach(() => {
    cookieManager = new CookieManager();
  });


  afterEach(() => {
    const allCookies = Cookies.get();
    for (const cookieName in allCookies) {
      if (Object.prototype.hasOwnProperty.call(allCookies, cookieName)) {
        Cookies.remove(cookieName);
      }
    }
  });

  describe('rememberSettings', () => {
    it('should return false if cookies_policy cookie is not set', () => {
      expect(cookieManager.rememberSettings()).toBe(false);
    });

    it('should return false if cookies_policy cookie is set but remember_settings is false', () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: false});
      expect(cookieManager.rememberSettings()).toBe(false);
    });

    it('should return true if cookies_policy cookie is set and remember_settings is true', () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      expect(cookieManager.rememberSettings()).toBe(true);
    });

    it('should return false if the remember_settings value is the string "false"', () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: 'false'});
      expect(cookieManager.rememberSettings()).toBe(false);
    });

    it('should return true if the remember_settings value is the string "true"', () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: 'true'});
      expect(cookieManager.rememberSettings()).toBe(true);
    });
  });

  describe('usage', () => {
    it('should return false if cookies_policy cookie is not set', () => {
      expect(cookieManager.usage()).toBe(false);
    });

    it('should return false if cookies_policy cookie is set but usage is false', () => {
      cookieManager.setCookiesPolicy({usage: false, remember_settings: true});
      expect(cookieManager.usage()).toBe(false);
    });

    it('should return true if cookies_policy cookie is set and usage is true', () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      expect(cookieManager.usage()).toBe(true);
    });

    it('should return false if the usage value is the string "false"', () => {
      cookieManager.setCookiesPolicy({usage: 'false', remember_settings: true});
      expect(cookieManager.usage()).toBe(false);
    });
  });

  describe('shouldOpenTree', () => {
    it('should return true if cookies_tree_open_closed_default cookie is not set', () => {
      expect(cookieManager.shouldOpenTree()).toBe(true);
    });

    it('should return true if cookies_tree_open_closed_default cookie is set to a string literal `open` value', () => {
      cookieManager.setCookiesTreeOpenClosedDefault({'value': 'open'});
      expect(cookieManager.shouldOpenTree()).toBe(true);
    });

    it('should return false if cookies_tree_open_closed_default cookie is set to a string literal `closed` value', () => {
      cookieManager.setCookiesTreeOpenClosedDefault({'value': 'closed'});
      expect(cookieManager.shouldOpenTree()).toBe(false);
    });
  });

  describe('showAcceptRejectCookiesBanner', () => {
    it('should return true if cookies_policy cookie is not set', () => {
      expect(cookieManager.showAcceptRejectCookiesBanner()).toBe(true);
    });

    it('should return false if cookies_policy cookie is set', () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      expect(cookieManager.showAcceptRejectCookiesBanner()).toBe(false);
    });
  });

  describe('showHideConfirmCookiesBanner', () => {
    it('should return true if cookies_hide_confirm cookie is not set', () => {
      expect(cookieManager.showHideConfirmCookiesBanner()).toBe(true);
    });

    it('should return false if cookies_hide_confirm cookie is set to a string literal `true` value', () => {
      cookieManager.setCookiesHideConfirm('true');
      expect(cookieManager.showHideConfirmCookiesBanner()).toBe(false);
    });

    it('should return false if cookies_hide_confirm cookie is set', () => {
      cookieManager.setCookiesHideConfirm({value: true});
      expect(cookieManager.showHideConfirmCookiesBanner()).toBe(false);
    });
  });

  describe('setCookiesPolicy', () => {
    it('should set cookies_policy cookie with default value', () => {
      cookieManager.setCookiesPolicy();
      expect(cookieManager.getCookiesPolicy()).toEqual({usage: true, remember_settings: true});
    });

    it('should set cookies_policy cookie with custom value', () => {
      const cookieValue = {usage: true, remember_settings: false};
      cookieManager.setCookiesPolicy(cookieValue);
      expect(cookieManager.getCookiesPolicy()).toEqual(cookieValue);
    });
  });

  describe('getCookiesPolicy', () => {
    it('should return null if cookies_policy cookie is not set', () => {
      expect(cookieManager.getCookiesPolicy()).toBe(null);
    });

    it('should return the cookies_policy cookie value if it is set', () => {
      const cookieValue = {usage: true, remember_settings: false};
      cookieManager.setCookiesPolicy(cookieValue);
      expect(cookieManager.getCookiesPolicy()).toEqual(cookieValue);
    });
  });

  describe('setCookiesHideConfirm', () => {
    it('should set cookies_hide_confirm cookie with default value', () => {
      cookieManager.setCookiesHideConfirm();
      expect(cookieManager.getCookiesHideConfirm()).toEqual({value: true});
    });

    it('should set cookies_hide_confirm cookie with custom value', () => {
      const cookieValue = {value: false};
      cookieManager.setCookiesHideConfirm(cookieValue);
      expect(cookieManager.getCookiesHideConfirm()).toEqual(cookieValue);
    });
  });

  describe('getCookiesHideConfirm', () => {
    it('should return null if cookies_hide_confirm cookie is not set', () => {
      expect(cookieManager.getCookiesHideConfirm()).toBe(null);
    });

    it('should return the cookies_hide_confirm cookie value if it is set', () => {
      const cookieValue = {value: false};
      cookieManager.setCookiesHideConfirm(cookieValue);
      expect(cookieManager.getCookiesHideConfirm()).toEqual(cookieValue);
    });
  });

  describe('setCookiesTreeOpenClosedDefault', () => {
    it('should set cookies_tree_open_closed_default cookie with default value', () => {
      cookieManager.setCookiesTreeOpenClosedDefault();
      expect(cookieManager.getCookiesTreeOpenClosedDefault()).toEqual('open');
    });

    it('should set cookies_tree_open_closed_default cookie with custom value', () => {
      const cookieValue = {value: 'closed'};
      cookieManager.setCookiesTreeOpenClosedDefault(cookieValue);
      expect(cookieManager.getCookiesTreeOpenClosedDefault()).toEqual('closed');
    });
  });

  describe('getCookiesTreeOpenClosedDefault', () => {
    it('should return `open` if cookies_tree_open_closed_default cookie is not set', () => {
      expect(cookieManager.getCookiesTreeOpenClosedDefault()).toEqual('open');
    });
  });
});
