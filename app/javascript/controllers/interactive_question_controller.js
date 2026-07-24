import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['pageHeader', 'header', 'form', 'dontKnow', 'thinking']
  static values = {
    eventUrl: String,
    questionNumber: Number,
    requestId: String,
  }

  connect() {
    this.questionShownAt = performance.now()
  }

  submitWithThinking(event) {
    event.preventDefault()

    if (this.#isUnknownAnswer(event.currentTarget)) {
      this.#recordDontKnow()
      this.#showDontKnow()
      return
    }

    this.#addElapsedTime(event.currentTarget)
    window.sessionStorage.setItem('guidedSearchSubmittedAt', Date.now().toString())

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

  #recordDontKnow() {
    if (!this.hasEventUrlValue) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    window.fetch(this.eventUrlValue, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({
        event_type: 'dont_know',
        request_id: this.requestIdValue,
        question_number: this.questionNumberValue,
        client_elapsed_ms: this.#clientElapsedMs(),
      }),
    }).catch(() => {})
  }

  #addElapsedTime(form) {
    const input = form.querySelector('input[name="client_elapsed_ms"]') || document.createElement('input')
    input.type = 'hidden'
    input.name = 'client_elapsed_ms'
    input.value = this.#clientElapsedMs()
    if (!input.parentNode) form.appendChild(input)
  }

  #clientElapsedMs() {
    return Math.max(0, Math.round(performance.now() - this.questionShownAt))
  }
}
