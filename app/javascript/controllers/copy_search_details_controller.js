import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'content']

  async copy() {
    const detailsText = this.hasContentTarget ? this.contentTarget : this.element.querySelector('.govuk-details__text')
    if (!detailsText) return

    const textContent = Array.from(detailsText.querySelectorAll('p'))
      .map((p) => p.textContent.trim())
      .join('\n')

    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(textContent)
        this.#showCopied()
        return
      } catch (_error) {
        // Fall back for browsers that expose the API but deny access.
      }
    }

    if (this.#fallbackCopy(textContent)) this.#showCopied()
  }

  #showCopied() {
    const original = this.buttonTarget.textContent.trim()
    this.buttonTarget.textContent = 'Copied'
    setTimeout(() => {
      this.buttonTarget.textContent = original
    }, 2000)
  }

  #fallbackCopy(text) {
    if (!document.execCommand) return false

    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.focus()
    textarea.select()
    textarea.setSelectionRange(0, textarea.value.length)

    try {
      return document.execCommand('copy')
    } catch (_error) {
      return false
    } finally {
      document.body.removeChild(textarea)
    }
  }
}
