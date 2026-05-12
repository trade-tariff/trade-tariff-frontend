import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  track(event) {
    if (!window.dataLayer) return

    const link = event.currentTarget

    window.dataLayer.push({
      event: link.dataset.analyticsEvent,
      link_id: link.id,
      link_text: link.textContent.trim(),
      link_url: link.href,
    })
  }
}
