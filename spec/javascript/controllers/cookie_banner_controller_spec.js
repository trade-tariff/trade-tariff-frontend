import {Application} from '@hotwired/stimulus';
import CookieBannerController from '../../../app/javascript/controllers/cookie_banner_controller';
import CookieManager from 'cookie-manager';
import Cookies from 'js-cookie';

describe('CookieBannerController', () => {
  let application;
  let cookieManager;
  let element;
  let controllerInstance;

  function resetCookies() {
    const allCookies = Cookies.get();
    for (const cookieName in allCookies) {
      if (Object.prototype.hasOwnProperty.call(allCookies, cookieName)) {
        Cookies.remove(cookieName);
      }
    }
  }

  beforeEach(() => {
    cookieManager = new CookieManager();

    element = document.createElement('div');
    element.setAttribute('data-controller', 'cookie-banner');
    element.innerHTML = `
      <div data-cookie-banner-target="banner">
        nothing changed
      </div>

      <div data-cookie-banner-target="hideThisMessageBannerAccepted" hidden="hidden">
        <button data-action="cookie-banner#hideConfirmCookiesBanner" class="cookie_hide_accepted_banner">
          Hide cookies banner accepted
        </button>
      </div>

      <div data-cookie-banner-target="hideThisMessageBannerRejected" hidden="hidden">
        <button data-action="cookie-banner#hideConfirmCookiesBanner" class="cookie_hide_rejected_banner">
          Hide cookies banner rejected
        </button>
      </div>

      <div data-cookie-banner-target="acceptRejectCookiesBanner" hidden="hidden">
        <button data-action="click->cookie-banner#acceptCookies" class="cookie_accept_all">
          Accept all cookies
        </button>
        <button data-action="click->cookie-banner#rejectCookies" class="cookie_reject_all">
          Reject all cookies
        </button>
      </div>
    `;

    document.body.appendChild(element);

    application = Application.start();
    application.register('cookie-banner', CookieBannerController);
  });

  afterEach(() => {
    application.unload();
    document.body.removeChild(element);
    resetCookies();
  });

  describe('connect', () => {
    it('should set the banner html to the accept reject target html by default', () => {
      cookieManager.setCookiesPolicy();
      application.start();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-banner');

      expect(controllerInstance.bannerTarget.innerHTML).toContain('Accept all cookies');
    });
  });

  describe('acceptCookies', () => {
    it('should set the cookies policy when we accept all cookies', () => {
      const acceptButton = element.querySelector('.cookie_accept_all');
      acceptButton.click();
      const cookiesPolicy = cookieManager.getCookiesPolicy();
      expect(cookiesPolicy).toEqual({
        usage: true,
        remember_settings: true,
      });
    });

    it('should set the banner html to the hide this message target html when we accept all cookies', () => {
      const acceptButton = element.querySelector('.cookie_accept_all');
      acceptButton.click();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-banner');
      expect(controllerInstance.bannerTarget.innerHTML).toContain('Hide cookies banner accepted');
    });
  });

  describe('rejectCookies', () => {
    it('should set the cookies policy when we reject all cookies', () => {
      const rejectButton = element.querySelector('.cookie_reject_all');
      rejectButton.click();
      const cookiesPolicy = cookieManager.getCookiesPolicy();
      expect(cookiesPolicy).toEqual({
        usage: false,
        remember_settings: false,
      });
    });

    it('should set the banner html to the hide this message target html when we reject all cookies', () => {
      const rejectButton = element.querySelector('.cookie_reject_all');
      rejectButton.click();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-banner');
      expect(controllerInstance.bannerTarget.innerHTML).toContain('Hide cookies banner rejected');
    });
  });

  describe('hideConfirmCookiesBanner', () => {
    it('should hide the banner when we click the hide button', () => {
      const hideButton = element.querySelector('.cookie_hide_accepted_banner');
      hideButton.click();

      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-banner');
      expect(controllerInstance.bannerTarget.hidden).toBe(true);
    });
  });
});
