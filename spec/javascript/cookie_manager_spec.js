import CookieManager from '../../app/javascript/src/cookie-manager';
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

    it.each([1, {}, [], null, undefined, 'yes'])('rejects malformed remember_settings value %p', (rememberSettings) => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: rememberSettings});
      expect(cookieManager.rememberSettings()).toBe(false);
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

    it('accepts the legacy string true value', () => {
      cookieManager.setCookiesPolicy({usage: 'true'});
      expect(cookieManager.usage()).toBe(true);
    });

    it.each([1, {}, [], null, undefined, 'yes'])('rejects malformed usage value %p', usage => {
      cookieManager.setCookiesPolicy({usage});
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

    it('clears the hierarchy choice when settings cookies are turned off', () => {
      cookieManager.setCommodityHierarchyOpen('open');
      cookieManager.setCookiesPolicy({usage: true, remember_settings: false});
      expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();

      cookieManager.setCommodityHierarchyOpen('open');
      cookieManager.setCookiesPolicy({usage: true, remember_settings: 'false'});
      expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
    });

    it('clears the commodity search choice when settings cookies are turned off', () => {
      cookieManager.setCommoditySearchOpen('open');
      cookieManager.setCookiesPolicy({usage: true, remember_settings: false});
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();

      cookieManager.setCommoditySearchOpen('closed');
      cookieManager.setCookiesPolicy({usage: true, remember_settings: 'false'});
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();
    });

    it('keeps the hierarchy and commodity search choices when settings cookies stay on', () => {
      cookieManager.setCommodityHierarchyOpen('open');
      cookieManager.setCommoditySearchOpen('open');
      cookieManager.setCookiesPolicy({usage: false, remember_settings: true});
      expect(cookieManager.getCommodityHierarchyOpen()).toEqual('open');
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');
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

  describe('commodity hierarchy open cookie', () => {
    it('stores an open or closed choice for 28 days', () => {
      const setCookie = jest.spyOn(Cookies, 'set');

      cookieManager.setCommodityHierarchyOpen('closed');

      expect(setCookie).toHaveBeenCalledWith(
          'commodity_hierarchy_open',
          JSON.stringify({value: 'closed'}),
          expect.objectContaining({expires: 28, sameSite: 'Strict'}),
      );
      expect(cookieManager.getCommodityHierarchyOpen()).toEqual('closed');
    });

    it('returns null when the cookie is missing or not a known choice', () => {
      expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();

      Cookies.set('commodity_hierarchy_open', JSON.stringify({value: 'maybe'}));
      expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
    });

    it('removes a stored choice and does not write a cookie when none exists', () => {
      const removeCookie = jest.spyOn(Cookies, 'remove');

      cookieManager.clearCommodityHierarchyOpen();
      expect(removeCookie).not.toHaveBeenCalled();

      cookieManager.setCommodityHierarchyOpen('open');
      cookieManager.clearCommodityHierarchyOpen();
      expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
    });
  });

  describe('commodity search open cookie', () => {
    it('stores an open or closed choice for 28 days', () => {
      const setCookie = jest.spyOn(Cookies, 'set');

      cookieManager.setCommoditySearchOpen('open');

      expect(setCookie).toHaveBeenCalledWith(
          'commodity_search_open',
          JSON.stringify({value: 'open'}),
          expect.objectContaining({expires: 28, sameSite: 'Strict'}),
      );
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');
    });

    it('returns null when the cookie is missing or not a known choice', () => {
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();

      Cookies.set('commodity_search_open', JSON.stringify({value: 'maybe'}));
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();
    });

    it('removes a stored choice and does not write a cookie when none exists', () => {
      // An earlier test in this file spies on Cookies.remove and jest does not
      // restore it, so clear the accumulated calls when picking the spy up.
      const removeCookie = jest.spyOn(Cookies, 'remove').mockClear();

      cookieManager.clearCommoditySearchOpen();
      expect(removeCookie).not.toHaveBeenCalled();

      cookieManager.setCommoditySearchOpen('closed');
      cookieManager.clearCommoditySearchOpen();
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();
    });

    it('is independent of the commodity hierarchy choice', () => {
      cookieManager.setCommodityHierarchyOpen('open');
      cookieManager.setCommoditySearchOpen('closed');

      cookieManager.clearCommoditySearchOpen();
      expect(cookieManager.getCommodityHierarchyOpen()).toEqual('open');
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();

      cookieManager.setCommoditySearchOpen('closed');
      cookieManager.clearCommodityHierarchyOpen();
      expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
      expect(cookieManager.getCommoditySearchOpen()).toEqual('closed');
    });
  });
});
