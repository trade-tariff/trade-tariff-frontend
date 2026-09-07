import { Controller } from '@hotwired/stimulus'
import { trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  static values = {
    eventUrl: String,
    outcome: String,
    requestId: String,
  }

  connect() {
    const submittedAt = Number(window.sessionStorage.getItem('guidedSearchSubmittedAt'))
    const navigationMs = Number.isFinite(submittedAt) && submittedAt > 0
      ? Math.max(0, Math.round(Date.now() - submittedAt)) : null

    trackSearchJourney('page_visible', { client_navigation_ms: navigationMs })
    if (navigationMs === null || !this.hasEventUrlValue) return

    window.sessionStorage.removeItem('guidedSearchSubmittedAt')

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    window.fetch(this.eventUrlValue, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({
        event_type: 'page_visible',
        request_id: this.requestIdValue,
        destination: this.outcomeValue,
        client_navigation_ms: navigationMs,
      }),
    }).catch(() => {})
  }
}
