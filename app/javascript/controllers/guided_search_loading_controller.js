import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['message', 'description']
  static values = { illustrative: Boolean, messages: Array }

  connect() {
    this.reset()
  }

  disconnect() {
    this.reset()
  }

  update({ detail: { status, followUp = false } }) {
    if (status === 'submitting') {
      this.reset()
      this.active = true
      this.followUp = followUp
      this.element.dataset.waiting = 'true'
      this.setMessage(followUp ? 'Sending your answer.' : 'Sending your search.')
      if (this.illustrativeValue && this.messages.length) this.startIllustration()
      return
    }

    if (status === 'stopped') {
      this.reset()
      return
    }

    if (status === 'navigating') {
      this.reset()
      this.setMessage('Loading the next page.')
      return
    }

    if (!this.active) return

    const messages = {
      queued: this.followUp ? 'The search with your answer is waiting to start.' : 'Your search is waiting to start.',
      running: this.followUp ? 'The service started the search with your answer.' : 'The service started your search.',
      retrying: 'We could not check the search status. We will try again.',
    }
    if (!messages[status]) return
    if (status === 'running' && this.illustrativeValue && this.messages.length) {
      this.startIllustration()
      return
    }
    this.stopIllustration()
    this.setMessage(messages[status])
  }

  // Timed messages are enabled only by the local prototype launcher.
  get messages() {
    return this.messagesValue.filter(entry => entry && typeof entry.text === 'string' &&
      Number.isFinite(entry.min_seconds) && entry.min_seconds > 0 &&
      Number.isFinite(entry.max_seconds) && entry.max_seconds >= entry.min_seconds)
  }

  startIllustration() {
    if (this.illustrating) return
    this.illustrating = true
    this.showIllustration()
  }

  showIllustration() {
    const messages = this.messages
    const current = messages[this.activityIndex]
    this.setMessage(current.text, current.description)
    if (this.activityIndex === messages.length - 1) return

    const seconds = current.min_seconds + Math.random() * (current.max_seconds - current.min_seconds)
    this.illustrationTimer = window.setTimeout(() => {
      this.activityIndex += 1
      this.showIllustration()
    }, seconds * 1000)
  }

  stopIllustration() {
    window.clearTimeout(this.illustrationTimer)
    this.illustrationTimer = null
    this.illustrating = false
  }

  restore(event) {
    if (event.persisted) this.reset()
  }

  reset() {
    this.stopIllustration()
    this.activityIndex = 0
    this.active = false
    this.element.dataset.waiting = 'false'
  }

  setMessage(text, description = '') {
    if (this.messageTarget.textContent !== text) this.messageTarget.textContent = text
    if (this.descriptionTarget.textContent !== description) this.descriptionTarget.textContent = description
  }
}
