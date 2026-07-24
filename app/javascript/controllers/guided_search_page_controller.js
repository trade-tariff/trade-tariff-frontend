import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    eventUrl: String,
    outcome: String,
    requestId: String,
  }

  connect() {
    const submittedAt = Number(window.sessionStorage.getItem('guidedSearchSubmittedAt'))
    if (!Number.isFinite(submittedAt) || submittedAt <= 0 || !this.hasEventUrlValue) return

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
        client_navigation_ms: Math.max(0, Math.round(Date.now() - submittedAt)),
      }),
    }).catch(() => {})
  }
}
