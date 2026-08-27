import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    context: Object,
    exposureEvent: String,
  }

  connect() {
    if (this.hasExposureEventValue) {
      this.push({event: this.exposureEventValue})
    }
  }

  track(event) {
    const link = event.currentTarget

    this.push({
      event: link.dataset.analyticsEvent,
      link_id: link.id,
      link_text: link.textContent.trim(),
      link_url: link.href,
    })
  }

  push(payload) {
    if (!window.dataLayer) return

    window.dataLayer.push({
      ...(this.hasContextValue ? this.contextValue : {}),
      ...payload,
    })
  }
}
