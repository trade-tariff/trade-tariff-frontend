import { Controller } from '@hotwired/stimulus'
import { newId, observationId, postJourneyEvent } from 'guided-search-journey'
import { markGuidedSearchPageVisible, trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  static values = {
    eventUrl: String,
    questionId: String,
    outcome: String,
    requestId: String,
  }

  connect() {
    this.onPageShow = event => {
      if (event.persisted) this.recordVisibility(newId())
    }
    window.addEventListener('pageshow', this.onPageShow)
    this.recordVisibility('initial')
  }

  disconnect() {
    window.removeEventListener('pageshow', this.onPageShow)
  }

  recordVisibility(observation) {
    markGuidedSearchPageVisible()
    const navigationMs = observation === 'initial' ? this.#navigationMs() : null

    trackSearchJourney('page_visible', { client_navigation_ms: navigationMs })
    if (!this.hasEventUrlValue) return

    try {
      window.sessionStorage.removeItem('guidedSearchSubmittedAt')
    } catch {
      // Timing is optional.
    }

    postJourneyEvent(this.eventUrlValue, {
      event_type: 'page_visible',
      request_id: this.requestIdValue,
      destination: this.outcomeValue,
      client_navigation_ms: navigationMs,
      question_id: this.hasQuestionIdValue ? this.questionIdValue : null,
      event_id: observationId(`page_visible:${this.outcomeValue}:${this.requestIdValue}:${observation}:${navigationMs ?? 'untimed'}`),
    })
  }

  #navigationMs() {
    try {
      const submittedAt = Number(window.sessionStorage.getItem('guidedSearchSubmittedAt'))
      return Number.isFinite(submittedAt) && submittedAt > 0
        ? Math.max(0, Math.round(Date.now() - submittedAt)) : null
    } catch {
      return null
    }
  }
}
