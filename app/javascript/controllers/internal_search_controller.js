import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['toggle', 'hiddenField']
  static values = {
    v2SuggestionsPath: String,
    internalSuggestionsPath: String,
  }

  connect() {
    const enabled = Cookies.get('internal_search') === 'true'
    this.toggleTarget.checked = enabled
    this.hiddenFieldTarget.value = enabled.toString()
    this.#updateSuggestionsPath(enabled)
  }

  toggle() {
    const enabled = this.toggleTarget.checked
    const isSecure = location.protocol === 'https:'

    Cookies.set('internal_search', enabled.toString(), {
      expires: 365,
      secure: isSecure,
      sameSite: 'Strict',
    })

    this.hiddenFieldTarget.value = enabled.toString()
    this.#updateSuggestionsPath(enabled)
  }

  #updateSuggestionsPath(enabled) {
    const pathInfoEl = document.querySelector('.path_info')

    if (pathInfoEl) {
      pathInfoEl.dataset.searchSuggestionsPath = enabled
        ? this.internalSuggestionsPathValue
        : this.v2SuggestionsPathValue
    }
  }
}
