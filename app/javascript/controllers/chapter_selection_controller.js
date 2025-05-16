import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
  }

  static targets = ['chapterCheckbox'];

  toggleAllChapterCheckboxes(event) {
    let checkboxes = this.chapterCheckboxTargets;
    checkboxes.forEach(checkbox => {
      checkbox.checked = event.currentTarget.value === 'true';
    });
  }
}
