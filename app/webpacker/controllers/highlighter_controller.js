import { Controller } from '@hotwired/stimulus';
import Mark from 'mark.js';

export default class extends Controller {
  connect() {
    this.highlight();
  }

  highlight() {
    const words = this.data.get('termValue').replace(/\+/g, ' ');
    const marker = new Mark(this.element);
    marker.mark(words, { className: 'highlight' });
  }
}
