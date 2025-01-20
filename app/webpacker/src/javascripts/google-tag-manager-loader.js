import CookieManager from './cookie-manager.js';

const cookieManager = new CookieManager();

if (cookieManager.usage()) {
  (function(w, d, s, l, i) {
    w[l] = w[l] || [];
    w[l].push({'gtm.start': new Date().getTime(), 'event': 'gtm.js'});
    const j = d.createElement(s);
    const dl = l != 'dataLayer' ? '&l=' + l : '';
    j.async = true;
    j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i + dl;
    document.head.insertBefore(j, document.head.firstChild);
  })(window, document, 'script', 'dataLayer', window.googleTagManagerContainerId);
}
