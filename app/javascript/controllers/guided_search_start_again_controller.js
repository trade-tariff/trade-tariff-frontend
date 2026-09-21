import { Controller } from '@hotwired/stimulus'
import { guidedSearchPageElapsedMs, searchAnalyticsContext, trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  static values = {
    eventUrl: String,
    requestId: String,
  }

  select() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const clientElapsedMs = guidedSearchPageElapsedMs()
    const destination = searchAnalyticsContext()?.search_state

    trackSearchJourney('start_again', { client_elapsed_ms: clientElapsedMs })

    if (!this.hasEventUrlValue) return

    window.fetch(this.eventUrlValue, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({
        event_type: 'start_again',
        request_id: this.requestIdValue,
        destination,
        client_elapsed_ms: clientElapsedMs,
      }),
    }).catch(() => {})
  }
}
