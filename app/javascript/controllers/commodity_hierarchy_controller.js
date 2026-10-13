import {Controller} from '@hotwired/stimulus';
import CookieManager from 'cookie-manager';

const OPEN = 'open';
const CLOSED = 'closed';
const RESTORING = 'data-commodity-hierarchy-restoring';

export default class extends Controller {
  connect() {
    this.cookieManager = new CookieManager();

    if (!this.cookieManager.rememberSettings()) {
      this.cookieManager.clearCommodityHierarchyOpen();
      return;
    }

    const preference = this.cookieManager.getCommodityHierarchyOpen();
    if (preference !== OPEN && preference !== CLOSED) return;

    this.#restore(preference === OPEN);
  }

  remember(event) {
    if (event.currentTarget.hasAttribute(RESTORING)) return;
    if (!this.cookieManager.rememberSettings()) return;

    const choice = event.currentTarget.open ? OPEN : CLOSED;
    this.cookieManager.setCommodityHierarchyOpen(choice);
  }

  // Setting open fires toggle. Mark that event so analytics and remember do not
  // treat restoration of a saved choice as a new click.
  #restore(open) {
    if (this.element.open === open) return;

    this.element.setAttribute(RESTORING, 'true');
    this.element.open = open;
    this.element.removeAttribute(RESTORING);
  }
}
