import { Controller } from '@hotwired/stimulus'
import { trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  static values = {
    confidence: String,
    eventUrl: String,
    goodsNomenclatureItemId: String,
    rank: Number,
    requestId: String,
  }

  select() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const confidence = this.hasConfidenceValue ? this.confidenceValue.toLowerCase() : 'unknown'

    trackSearchJourney('result_selected', {
      goods_nomenclature_item_id: this.goodsNomenclatureItemIdValue,
      result_rank: this.rankValue,
      confidence,
    })

    window.fetch(this.eventUrlValue, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({
        event_type: 'result_selected',
        request_id: this.requestIdValue,
        goods_nomenclature_item_id: this.goodsNomenclatureItemIdValue,
        result_rank: this.rankValue,
        confidence,
      }),
    }).catch(() => {})
  }
}
