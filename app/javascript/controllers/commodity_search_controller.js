import { Controller } from '@hotwired/stimulus';
import CookieManager from 'cookie-manager';

const OPEN = 'open';
const CLOSED = 'closed';

export default class extends Controller {
  static targets = ['trigger', 'panel'];

  connect() {
    this.cookieManager = new CookieManager();

    this.triggerTarget.setAttribute('role', 'button');
    this.triggerTarget.setAttribute('aria-controls', this.panelTarget.id);
    this.triggerTarget.setAttribute('aria-expanded', 'false');

    if (this.cookieManager.rememberSettings() !== true) {
      this.cookieManager.clearCommoditySearchOpen();
      return;
    }

    const preference = this.cookieManager.getCommoditySearchOpen();
    if (preference !== OPEN && preference !== CLOSED) return;

    this.#restore(preference === OPEN);
  }

  toggle(event) {
    // The link is a real navigation fallback without JavaScript. With
    // JavaScript the link only toggles the panel, so stop the navigation.
    event.preventDefault();
    this.panelTarget.hidden ? this.#open() : this.#close();
  }

  close() {
    this.#close();
  }

  keydown(event) {
    if (event.key === ' ' && event.target === this.triggerTarget && this.#noModifiers(event)) {
      // A link with role="button" does not activate on Space natively.
      event.preventDefault();
      this.panelTarget.hidden ? this.#open() : this.#close();
      return;
    }

    if (event.key === 'Escape' && this.element.contains(event.target)) {
      this.#close();
      return;
    }
  }

  #open() {
    this.panelTarget.hidden = false;
    this.triggerTarget.setAttribute('aria-expanded', 'true');
    this.#remember(OPEN);
    this.#focusActiveSearchInput();
  }

  #close() {
    if (this.panelTarget.hidden) return;

    this.panelTarget.hidden = true;
    this.triggerTarget.setAttribute('aria-expanded', 'false');
    this.#remember(CLOSED);
    this.triggerTarget.focus({ preventScroll: true });
  }

  // Restores the stored choice without writing the cookie again and without
  // moving focus, so a page load never steals focus from the user.
  #restore(open) {
    this.panelTarget.hidden = !open;
    this.triggerTarget.setAttribute('aria-expanded', open.toString());
  }

  #remember(choice) {
    if (this.cookieManager.rememberSettings() !== true) return;

    this.cookieManager.setCommoditySearchOpen(choice);
  }

  // The search-mode controller enables only the inputs of the active search
  // section, so the first enabled visible input or textarea is the active one.
  #focusActiveSearchInput() {
    const candidates = this.panelTarget.querySelectorAll('input:not([type="hidden"]), textarea');
    const active = Array.from(candidates).find((element) =>
      !element.disabled && element.id !== 'resource_id' && !element.closest('[hidden]'));

    active?.focus({ preventScroll: true });
  }

  #noModifiers(event) {
    return !event.ctrlKey && !event.metaKey && !event.altKey && !event.shiftKey;
  }
}
