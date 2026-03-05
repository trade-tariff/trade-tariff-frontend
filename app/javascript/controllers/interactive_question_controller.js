import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form', 'dontKnow', 'thinking']

  submitWithThinking(event) {
    if (this.hasThinkingTarget && this.hasFormTarget) {
      this.formTarget.classList.add('govuk-!-display-none')
      this.thinkingTarget.classList.remove('govuk-!-display-none')
    }
  }

  selectUnknown(event) {
    // When "I don't know" is selected, show the dedicated page
    // Use a small delay to show the selection before transitioning
    setTimeout(() => this.#showDontKnow(), 150)
  }

  goBack() {
    if (this.hasDontKnowTarget) {
      this.dontKnowTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasFormTarget) {
      this.formTarget.classList.remove('govuk-!-display-none')
    }
  }

  #showDontKnow() {
    if (this.hasFormTarget) {
      this.formTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasDontKnowTarget) {
      this.dontKnowTarget.classList.remove('govuk-!-display-none')
    }
  }
}
