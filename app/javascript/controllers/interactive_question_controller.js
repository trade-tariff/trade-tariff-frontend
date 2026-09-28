import { Controller } from '@hotwired/stimulus'
import { currentJourney, newId, observationId, postJourneyEvent, readField, validId, writeField } from 'guided-search-journey'
import { trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  static targets = ['pageHeader', 'header', 'form', 'dontKnow', 'thinking']
  static values = {
    eventUrl: String,
    questionId: String,
    questionNumber: Number,
    requestId: String,
  }

  connect() {
    this.questionShownAt = performance.now()
    this.boundRestoreFromBfcache = this.#restoreFromBfcache.bind(this)
    window.addEventListener('pageshow', this.boundRestoreFromBfcache)
  }

  disconnect() {
    window.removeEventListener('pageshow', this.boundRestoreFromBfcache)
  }

  submitWithThinking(event) {
    event.preventDefault()
    if (this.answerSent) return
    this.submissionId = newId()

    if (this.#isUnknownAnswer(event.currentTarget)) {
      this.answerSent = true
      this.#recordDontKnow()
      this.#showDontKnow()
      return
    }

    this.answerSent = true
    if (this.#selectedOption(event.currentTarget)) this.#recordAnswer(event.currentTarget)
    this.#addElapsedTime(event.currentTarget)
    try {
      window.sessionStorage.setItem('guidedSearchSubmittedAt', Date.now().toString())
    } catch {
      // Navigation timing is optional.
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
    this.answerSent = false
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
    window.setTimeout(() => {
      const event = new CustomEvent('guided-search:submit', { bubbles: true, cancelable: true, detail: { form } })
      if (form.dispatchEvent(event)) HTMLFormElement.prototype.submit.call(form)
    }, 0)
  }

  restore() {
    this.#restoreFromBfcache({ persisted: true })
  }

  #recordDontKnow() {
    const elapsedMs = this.#clientElapsedMs()
    const identity = this.#identity()
    trackSearchJourney('dont_know', {
      used_dont_know: true,
      question_count: this.questionNumberValue,
      client_elapsed_ms: elapsedMs,
    })

    postJourneyEvent(this.hasEventUrlValue ? this.eventUrlValue : null, {
      event_type: 'dont_know',
      request_id: this.requestIdValue,
      question_number: this.questionNumberValue,
      client_elapsed_ms: elapsedMs,
      journey_id: identity.journeyId,
      question_id: identity.questionId,
      submission_id: identity.submissionId,
      event_id: observationId(`dont_know:${identity.questionId}:${identity.submissionId}`),
      question_response: 'dont_know',
      terminal_outcome: 'dont_know',
    })
  }

  #selectedOption(form) {
    const answer = form.querySelector('input[type="radio"][name$="[answer]"]:checked')
    if (!answer || answer.dataset.guidedOption !== 'true' || !answer.value) return null
    return answer
  }

  #recordAnswer(form) {
    const identity = this.#identity()
    writeField(form, 'telemetry_journey_id', identity.journeyId)
    writeField(form, 'telemetry_submission_id', identity.submissionId)
    if (!readField(form, 'telemetry_question_id')) writeField(form, 'telemetry_question_id', identity.questionId)
    postJourneyEvent(this.hasEventUrlValue ? this.eventUrlValue : null, {
      event_type: 'answer_submitted',
      response_source: 'browser_selected',
      question_response: 'browser_selected',
      request_id: this.requestIdValue,
      question_number: this.questionNumberValue,
      client_elapsed_ms: this.#clientElapsedMs(),
      journey_id: identity.journeyId,
      question_id: identity.questionId,
      submission_id: identity.submissionId,
      event_id: observationId(`answer:${identity.questionId}:${identity.submissionId}`),
    })
  }

  #identity() {
    const form = this.element.querySelector('form')
    return {
      journeyId: currentJourney(form),
      questionId: this.#renderedQuestionId(form),
      submissionId: this.submissionId,
    }
  }

  #renderedQuestionId(form) {
    return validId(this.hasQuestionIdValue ? this.questionIdValue : null) || readField(form, 'telemetry_question_id')
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

  #restoreFromBfcache(event) {
    if (!event.persisted) return

    this.questionShownAt = performance.now()
    this.answerSent = false

    if (this.hasPageHeaderTarget) {
      this.pageHeaderTarget.classList.remove('govuk-!-display-none')
    }
    if (this.hasHeaderTarget) {
      this.headerTarget.classList.remove('govuk-!-display-none')
    }
    if (this.hasFormTarget) {
      this.formTarget.classList.remove('govuk-!-display-none')
    }
    if (this.hasThinkingTarget) {
      this.thinkingTarget.classList.add('govuk-!-display-none')
    }
    if (this.hasDontKnowTarget) {
      this.dontKnowTarget.classList.add('govuk-!-display-none')
    }
  }
}
