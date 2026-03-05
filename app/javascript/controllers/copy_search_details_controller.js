import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button']

  async copy() {
    const detailsText = this.element.querySelector('.govuk-details__text')
    if (!detailsText) return

    const textContent = Array.from(detailsText.querySelectorAll('p'))
      .map((p) => p.textContent.trim())
      .join('\n')

    try {
      await navigator.clipboard.writeText(textContent)
      this.#showCopied()
    } catch {
      // Fallback for older browsers or non-HTTPS contexts
      this.#fallbackCopy(textContent)
    }
  }

  #showCopied() {
    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = 'Copied'
    setTimeout(() => {
      this.buttonTarget.textContent = original
    }, 2000)
  }

  #fallbackCopy(text) {
    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    this.#showCopied()
  }
}
