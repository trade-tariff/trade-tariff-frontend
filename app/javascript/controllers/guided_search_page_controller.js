import { Controller } from '@hotwired/stimulus'
import { currentJourney, observationId, postJourneyEvent, rememberJourney } from 'guided-search-journey'
import { markGuidedSearchPageVisible, trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  static values = {
    eventUrl: String,
    journeyId: String,
    questionId: String,
    outcome: String,
    requestId: String,
  }

  connect() {
    markGuidedSearchPageVisible()
    rememberJourney(this.hasJourneyIdValue ? this.journeyIdValue : null)
    const navigationMs = this.#navigationMs()

    trackSearchJourney('page_visible', { client_navigation_ms: navigationMs })
    if (!this.hasEventUrlValue) return

    try {
      window.sessionStorage.removeItem('guidedSearchSubmittedAt')
    } catch {
      // Timing is optional.
    }

    const journeyId = currentJourney() || (this.hasJourneyIdValue ? this.journeyIdValue : null)
    postJourneyEvent(this.eventUrlValue, {
      event_type: 'page_visible',
      request_id: this.requestIdValue,
      destination: this.outcomeValue,
      client_navigation_ms: navigationMs,
      journey_id: journeyId,
      question_id: this.hasQuestionIdValue ? this.questionIdValue : null,
      event_id: observationId(`page_visible:${this.outcomeValue}:${this.requestIdValue}:${navigationMs ?? 'untimed'}`),
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
