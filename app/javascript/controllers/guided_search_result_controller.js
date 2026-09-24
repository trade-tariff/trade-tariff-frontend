import { Controller } from '@hotwired/stimulus'
import { guidedSearchPageElapsedMs, trackSearchJourney } from 'search-analytics'

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
    const clientElapsedMs = guidedSearchPageElapsedMs()

    trackSearchJourney('result_selected', {
      goods_nomenclature_item_id: this.goodsNomenclatureItemIdValue,
      result_rank: this.rankValue,
      confidence,
      client_elapsed_ms: clientElapsedMs,
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
        client_elapsed_ms: clientElapsedMs,
      }),
    }).catch(() => {})
  }
}
