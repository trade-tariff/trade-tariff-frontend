import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static values = {url: String};

  connect() {
    this.loaded = false;
    this.loading = false;
    this._handleClick = () => this.load();

    if (window.location.hash === '#rules-of-origin') {
      this.load();
    }

    this._tabLink = document.querySelector('a[href="#rules-of-origin"]');
    if (this._tabLink) {
      this._tabLink.addEventListener('click', this._handleClick);
    }
  }

  disconnect() {
    if (this._tabLink) {
      this._tabLink.removeEventListener('click', this._handleClick);
    }
  }

  async load() {
    if (this.loaded || this.loading) return;

    this.loading = true;

    try {
      const response = await fetch(this.urlValue, {
        headers: {'Accept': 'text/html'},
      });

      if (!response.ok) throw new Error(`HTTP ${response.status}`);

      this.element.innerHTML = await response.text();
      this.loaded = true;
    } catch {
      this.element.innerHTML =
        '<p class="govuk-error-message">Sorry, this content could not be loaded. Please refresh the page to try again.</p>';
    } finally {
      this.loading = false;
    }
  }
}
