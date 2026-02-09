import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form', 'results']

  selectUnknown(event) {
    // When "I don't know" is selected, show pre-rendered results
    // Use a small delay to show the selection before transitioning
    setTimeout(() => this.#showResults(), 150)
  }

  #showResults() {
    if (this.hasFormTarget) {
      this.formTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.remove('govuk-!-display-none')
    }
  }
}
