import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['toggle', 'hiddenField', 'guidedInput']
  static values = {
    v2SuggestionsPath: String,
    interactiveSuggestionsPath: String,
  }

  connect() {
    const guided = Cookies.get('interactive_search') === 'true'

    this.toggleTargets.forEach((radio) => {
      radio.checked = guided ? radio.value === 'guided' : radio.value === 'keyword'
    })

    this.hiddenFieldTarget.value = guided.toString()
    this.#updateSuggestionsPath(guided)
    this.#syncInputs(guided)

    // Trigger GOV.UK conditional reveal by dispatching a click on the checked radio
    const checkedRadio = this.toggleTargets.find((r) => r.checked)
    if (checkedRadio) {
      checkedRadio.dispatchEvent(new Event('click', { bubbles: true }))
    }
  }

  toggle(event) {
    const guided = event.target.value === 'guided'
    const isSecure = location.protocol === 'https:'

    Cookies.set('interactive_search', guided.toString(), {
      expires: 365,
      secure: isSecure,
      sameSite: 'Strict',
    })

    this.hiddenFieldTarget.value = guided.toString()
    this.#updateSuggestionsPath(guided)
    this.#syncInputs(guided)
  }

  #updateSuggestionsPath(guided) {
    const pathInfoEl = document.querySelector('.path_info')

    if (pathInfoEl) {
      pathInfoEl.dataset.searchSuggestionsPath = guided
        ? this.interactiveSuggestionsPathValue
        : this.v2SuggestionsPathValue
    }
  }

  #syncInputs(guided) {
    // Disable the inactive input so only one q value submits
    const autocompleteInput = document.querySelector('#autocomplete input[name="q"], #q')

    if (this.hasGuidedInputTarget) {
      this.guidedInputTarget.disabled = !guided
    }

    if (autocompleteInput) {
      autocompleteInput.disabled = guided
    }
  }
}
