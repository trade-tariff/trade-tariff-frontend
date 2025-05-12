import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    // accordion doesn't allow sections to be open by default
    // so we need to open the first section manually (perhaps we can do it for selected sections??)
    this.showAccordionSection(1);
  }

  static targets = ['chapterCheckbox'];

  toggleAllChapterCheckboxes(event) {
    let checkboxes = this.chapterCheckboxTargets;
    checkboxes.forEach(checkbox => {
      checkbox.checked = event.currentTarget.value === 'true';
    });
  }

  removeChapter(event) {
    event.preventDefault()
    const chapterId = event.target.dataset.chapterId
    fetch("/subscriptions/remove_chapter_selection", {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ chapter_id: chapterId })
    }).then(response => {
      if (response.ok) {
        event.target.closest("tr").remove()
      } else {
        console.error("Failed to remove chapter")
      }
    })
  }

  showAccordionSection(sectionId) {
    const button = document.querySelector(`#accordion-section-${sectionId} .govuk-accordion__section-button`);
    if (button && button.textContent.includes(", Show")) {
      button.click();
    }
  }
}
