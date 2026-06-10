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
            <input id="cookies_policy_usage_true" type="radio" value="true" name="cookies_policy[usage]">
          </div>
          <div class="govuk-radios__item">
            <input id="cookies_policy_usage_false" type="radio" value="false" name="cookies_policy[usage]">
          </div>
        </div>

        <div class="govuk-radios govuk-radios--stacked">
          <div class="govuk-radios__item">
            <input id="cookies_policy_remember_settings_true" type="radio" value="true" name="cookies_policy[remember_settings]">
          </div>
          <div class="govuk-radios__item">
            <input id="cookies_policy_remember_settings_false" type="radio" value="false" name="cookies_policy[remember_settings]">
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
      const usageRadioTrue = element.querySelector('#cookies_policy_usage_true');
      const usageRadioFalse = element.querySelector('#cookies_policy_usage_false');
      const rememberSettingsRadioTrue = element.querySelector('#cookies_policy_remember_settings_true');
      const rememberSettingsRadioFalse = element.querySelector('#cookies_policy_remember_settings_false');

      expect(controllerInstance).toBeDefined();
      expect(usageRadioTrue.checked).toEqual(false);
      expect(usageRadioFalse.checked).toEqual(false);
      expect(rememberSettingsRadioTrue.checked).toEqual(false);
      expect(rememberSettingsRadioFalse.checked).toEqual(false);
    });

    it('should restore checked options from an existing cookies policy', () => {
      cookieManager.setCookiesPolicy({usage: false, remember_settings: true});

      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-policy');
      controllerInstance.connect();
      const usageRadioFalse = element.querySelector('#cookies_policy_usage_false');
      const rememberSettingsRadioTrue = element.querySelector('#cookies_policy_remember_settings_true');

      expect(controllerInstance).toBeDefined();
      expect(usageRadioFalse.checked).toEqual(true);
      expect(rememberSettingsRadioTrue.checked).toEqual(true);
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

    it('should set the cookies policy when only one option group is selected and default the other to false', () => {
      application.start();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-policy');
      const usageRadioTrue = element.querySelector('#cookies_policy_usage_true');
      const successMessage = element.querySelector('[data-cookie-policy-target="successMessage"]');

      usageRadioTrue.checked = true;

      const form = element.querySelector('form');
      const submitEvent = new Event('submit', {bubbles: true, cancelable: true});
      form.dispatchEvent(submitEvent);

      expect(cookieManager.getCookiesPolicy()).toEqual({usage: true, remember_settings: false});
      expect(successMessage.hidden).toEqual(false);
    });

    it('should set the cookies policy when we submit the form and the options are picked', () => {
      application.start();
      controllerInstance = application.getControllerForElementAndIdentifier(element, 'cookie-policy');
      const usageRadioTrue = element.querySelector('#cookies_policy_usage_true');
      const rememberSettingsRadioTrue = element.querySelector('#cookies_policy_remember_settings_true');

      usageRadioTrue.checked = true;
      rememberSettingsRadioTrue.checked = true;

      const form = element.querySelector('form');
      const submitEvent = new Event('submit', {bubbles: true, cancelable: true});
      form.dispatchEvent(submitEvent);

      expect(cookieManager.getCookiesPolicy()).toEqual({usage: true, remember_settings: true});
    });
  });
});
