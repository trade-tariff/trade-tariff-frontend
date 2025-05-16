
import {Controller} from '@hotwired/stimulus';

import CookieManager from 'cookie-manager';

export default class extends Controller {
  static targets = [
    'banner',
    'acceptRejectCookiesBanner',
    'hideThisMessageBannerAccepted',
    'hideThisMessageBannerRejected',
  ];

  connect() {
    this.cookieManager = new CookieManager();

    if (this.hasBannerTarget) {
      this.#updateBannerBasedOnCookies();
    }
  }

  acceptCookies(event) {
    event.preventDefault();
    this.cookieManager.setCookiesPolicy({
      usage: true,
      remember_settings: true,
    });
    this.bannerTarget.innerHTML = this.hideThisMessageBannerAcceptedTarget.innerHTML;
  }

  rejectCookies(event) {
    event.preventDefault();
    this.cookieManager.setCookiesPolicy({
      usage: false,
      remember_settings: false,
    });
    this.bannerTarget.innerHTML = this.hideThisMessageBannerRejectedTarget.innerHTML;
  }

  hideConfirmCookiesBanner(event) {
    event.preventDefault();
    this.cookieManager.setCookiesHideConfirm({value: true});
    this.#hideCookiesBanner();
  }

  #updateBannerBasedOnCookies() {
    const showAcceptReject = this.cookieManager.showAcceptRejectCookiesBanner();
    const showHideConfirm = this.cookieManager.showHideConfirmCookiesBanner();

    if (showAcceptReject) {
      this.#showAcceptRejectCookiesBanner();
    } else if (showHideConfirm) {
      this.#showHideConfirmCookiesBanner();
    } else {
      this.#hideCookiesBanner();
    }
  }

  #showAcceptRejectCookiesBanner() {
    this.bannerTarget.innerHTML = this.acceptRejectCookiesBannerTarget.innerHTML;
  }

  #showHideConfirmCookiesBanner() {
    const showHideConfirm = this.cookieManager.showHideConfirmCookiesBanner();

    if (showHideConfirm && this.cookieManager.usage()) {
      this.bannerTarget.innerHTML = this.hideThisMessageBannerAcceptedTarget.innerHTML;
    } else {
      this.bannerTarget.innerHTML = this.hideThisMessageBannerRejectedTarget.innerHTML;
    }
  }

  #hideCookiesBanner() {
    this.bannerTarget.hidden = true;
  }
}
