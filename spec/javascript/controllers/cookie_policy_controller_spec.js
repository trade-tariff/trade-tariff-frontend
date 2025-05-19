import { Application } from '@hotwired/stimulus';
import CookiePolicyController from '../../../app/javascript/controllers/cookie_policy_controller';
import CookieManager from '../../../app/javascript/src/cookie-manager';
import Cookies from 'js-cookie';

describe('CookiePolicyController', () => {
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
    // Mock the scrollIntoView method on the HTMLElement prototype - JSDOM does not support it
    window.HTMLElement.prototype.scrollIntoView = function() {};
    cookieManager = new CookieManager();

    element = document.createElement('div');
    element.setAttribute('data-controller', 'cookie-policy');
    element.innerHTML = `

      <form data-action="submit->cookie-policy#updatePolicy">
        <div data-cookie-policy-target="successMessage" hidden="hidden">
          Success message
        </div>

        <div class="govuk-radios govuk-radios--stacked">
          <div class="govuk-radios__item">
            <input type="radio" value="true" name="cookies_policy[usage]" data-cookie-policy-target="usageRadioTrue">
          </div>
          <div class="govuk-radios__item">
            <input type="radio" value="false" name="cookies_policy[usage]" data-cookie-policy-target="usageRadioFalse">
          </div>
        </div>

        <div class="govuk-radios govuk-radios--stacked">
          <div class="govuk-radios__item">
            <input type="radio" value="true" data-cookie-policy-target="rememberSettingsRadioTrue">
          </div>
          <div class="govuk-radios__item">
            <input type="radio" value="false" data-cookie-policy-target="rememberSettingsRadioFalse">
          </div>
        </div>

        <input type="submit" name="commit">
      </form>
    `;

    document.body.appendChild(element);

    application = Application.start();
    application.register('cookie-policy', CookiePolicyController);
  });

  afterEach(() => {
    application.unload();
    document.body.removeChild(element);
    resetCookies();
  });

  describe('connect', () => {
    it('should set the all options to unchecked by default', () => {
      application.start();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-policy');

      expect(controllerInstance.usageRadioTrueTarget.checked).toEqual(false);
      expect(controllerInstance.usageRadioFalseTarget.checked).toEqual(false);
      expect(controllerInstance.rememberSettingsRadioTrueTarget.checked).toEqual(false);
      expect(controllerInstance.rememberSettingsRadioFalseTarget.checked).toEqual(false);
    });
  });

  describe('updatePolicy', () => {
    it('should not set the cookies policy when we submit the form and no options are picked', () => {
      application.start();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-policy');

      const form = element.querySelector('form');
      const submitEvent = new Event('submit', {bubbles: true, cancelable: true});
      form.dispatchEvent(submitEvent);

      expect(cookieManager.getCookiesPolicy()).toEqual(null);
    });

    it('should set the cookies policy when we submit the form and the options are picked', () => {
      application.start();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-policy');

      controllerInstance.usageRadioTrueTarget.checked = true;
      controllerInstance.rememberSettingsRadioTrueTarget.checked = true;

      const form = element.querySelector('form');
      const submitEvent = new Event('submit', {bubbles: true, cancelable: true});
      form.dispatchEvent(submitEvent);

      expect(cookieManager.getCookiesPolicy()).toEqual({usage: true, remember_settings: true});
    });
  });
});
