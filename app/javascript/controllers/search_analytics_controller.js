import { Controller } from '@hotwired/stimulus'
import { publishSearchContext, searchAnalyticsContext, trackSearchJourney } from 'search-analytics'

export default class extends Controller {
  connect() {
    const context = searchAnalyticsContext()
    if (!context?.search_state) return
    // Guided pages publish with their existing submit-to-visible timing.
    if (context.search_mode === 'guided' && context.search_state !== 'entry') return

    trackSearchJourney('page_visible')
  }

  submit(event) {
    publishSearchContext(event.target)
  }
}
