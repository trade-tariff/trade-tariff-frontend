import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['toggle', 'hiddenField', 'guidedInput', 'guidedSection', 'keywordSection']
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
    this.#syncConditionals(guided)
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
    this.#syncConditionals(guided)
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

  #syncConditionals(guided) {
    this.#toggleSection(this.guidedSectionTarget, guided)
    this.#toggleSection(this.keywordSectionTarget, !guided)
  }

  #toggleSection(section, visible) {
    section.classList.toggle('govuk-radios__conditional--hidden', !visible)
    section.toggleAttribute('hidden', !visible)
  }
}
