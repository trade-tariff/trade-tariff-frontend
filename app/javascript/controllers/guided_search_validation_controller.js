import { Controller } from '@hotwired/stimulus'

const MAX_QUERY_LENGTH = 500
const MIN_QUERY_LENGTH = 2

export default class extends Controller {
  static targets = ['hiddenField', 'textarea', 'formGroup', 'formContent', 'thinking']

  validateAndSubmit(event) {
    if (this.hiddenFieldTarget.value !== 'true') return

    event.preventDefault()

    const value = this.textareaTarget.value.trim()
    const errors = this.#validate(value)

    this.#clearErrors()

    if (errors.length > 0) {
      this.#showErrors(errors)
    } else {
      this.#showThrobber()
      this.element.submit()
    }
  }

  #validate(value) {
    const errors = []

    if (value === '') {
      errors.push('Enter a search term')
    } else if (value.length < MIN_QUERY_LENGTH) {
      errors.push('Search term must be at least 2 characters')
    } else if (value.length > MAX_QUERY_LENGTH) {
      errors.push('Search term must be 100 characters or fewer')
    }

    return errors
  }

  #clearErrors() {
    const summary = this.element.querySelector('.govuk-error-summary')
    if (summary) summary.remove()

    const inlineError = this.element.querySelector('#guided-q-error')
    if (inlineError) inlineError.remove()

    this.formGroupTarget.classList.remove('govuk-form-group--error')
    this.textareaTarget.classList.remove('govuk-textarea--error')
    this.textareaTarget.setAttribute('aria-describedby', 'guided-q-hint')
  }

  #showErrors(errors) {
    const summary = document.createElement('div')
    summary.className = 'govuk-error-summary'
    summary.setAttribute('data-module', 'govuk-error-summary')
    summary.innerHTML = `
      <div role="alert">
        <h2 class="govuk-error-summary__title">There is a problem</h2>
        <div class="govuk-error-summary__body">
          <ul class="govuk-list govuk-error-summary__list">
            ${errors.map((msg) => `<li><a href="#guided_q">${msg}</a></li>`).join('')}
          </ul>
        </div>
      </div>
    `

    this.formContentTarget.prepend(summary)

    this.formGroupTarget.classList.add('govuk-form-group--error')
    this.textareaTarget.classList.add('govuk-textarea--error')

    const inlineError = document.createElement('p')
    inlineError.className = 'govuk-error-message'
    inlineError.id = 'guided-q-error'
    inlineError.innerHTML = `<span class="govuk-visually-hidden">Error:</span> ${errors.join('. ')}`

    this.textareaTarget.before(inlineError)
    this.textareaTarget.setAttribute('aria-describedby', 'guided-q-hint guided-q-error')

    summary.focus()
  }

  #showThrobber() {
    this.formContentTarget.classList.add('govuk-!-display-none')
    this.thinkingTarget.classList.remove('govuk-!-display-none')
  }
}
