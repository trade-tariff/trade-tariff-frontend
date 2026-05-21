import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['pageHeader', 'header', 'form', 'dontKnow', 'thinking']

  submitWithThinking(event) {
    event.preventDefault()

    if (this.#isUnknownAnswer(event.currentTarget)) {
      this.#showDontKnow()
      return
    }

    if (this.hasPageHeaderTarget) {
      this.pageHeaderTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasHeaderTarget) {
      this.headerTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasThinkingTarget && this.hasFormTarget) {
      this.formTarget.classList.add('govuk-!-display-none')
      this.thinkingTarget.classList.remove('govuk-!-display-none')
    }

    this.#submitForm(event.currentTarget)
  }

  goBack() {
    if (this.hasDontKnowTarget) {
      this.dontKnowTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasPageHeaderTarget) {
      this.pageHeaderTarget.classList.remove('govuk-!-display-none')
    }
    if (this.hasHeaderTarget) {
      this.headerTarget.classList.remove('govuk-!-display-none')
    }
    if (this.hasFormTarget) {
      this.formTarget.classList.remove('govuk-!-display-none')
    }
  }

  #showDontKnow() {
    if (this.hasPageHeaderTarget) {
      this.pageHeaderTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasHeaderTarget) {
      this.headerTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasFormTarget) {
      this.formTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasDontKnowTarget) {
      this.dontKnowTarget.classList.remove('govuk-!-display-none')
    }
  }

  #isUnknownAnswer(form) {
    const answer = form.querySelector('input[type="radio"][name$="[answer]"]:checked')

    return answer?.value === "I don't know"
  }

  #submitForm(form) {
    window.setTimeout(() => HTMLFormElement.prototype.submit.call(form), 0)
  }
}
