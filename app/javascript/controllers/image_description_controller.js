import { Controller } from '@hotwired/stimulus'

const MAX_BYTES = 15 * 1024 * 1024
const FORMATS = /\.(jpe?g|png|webp|gif|heic|heif|avif|tiff?)$/i
const RECOVERY = 'We could not describe this image. Try again or enter a description.'
const ERRORS = {
  403: 'Copy your description, then reload the page to try again.',
  404: 'Image upload is unavailable. Enter a description.',
  413: 'Choose an image smaller than 15MB.',
  415: 'We could not use this image. Choose another image.',
  422: 'We could not read this image. Choose another image.',
  503: 'Image upload is unavailable. Try again later or enter a description.',
}

export default class extends Controller {
  static targets = ['textarea', 'controls', 'file', 'status', 'error', 'cancel', 'retry']
  static values = { url: String }

  connect() {
    this.controlsTarget.hidden = false
    this.retryTarget.hidden = !this.image
    this.boundGuard = this.guardSubmit.bind(this)
    this.boundLeave = () => this.interrupt()
    // Capture before guided-search validation hides the form or queues a search.
    this.element.addEventListener('submit', this.boundGuard, true)
    window.addEventListener('pagehide', this.boundLeave)
  }

  disconnect() {
    this.interrupt()
    this.image = null
    this.element.removeEventListener('submit', this.boundGuard, true)
    window.removeEventListener('pagehide', this.boundLeave)
  }

  guardSubmit(event) {
    if (!this.run || this.textareaTarget.disabled) return

    event.preventDefault()
    event.stopImmediatePropagation()
    this.statusTarget.textContent = 'Wait for the description or select Cancel.'
    this.cancelTarget.focus()
  }

  dragover(event) {
    if (event.dataTransfer?.types.includes('Files')) {
      event.preventDefault()
      event.dataTransfer.dropEffect = 'copy'
    }
  }

  drop(event) {
    if (!event.dataTransfer?.files.length) return

    event.preventDefault()
    this.select(Array.from(event.dataTransfer.files))
  }

  choose() {
    const files = Array.from(this.fileTarget.files)
    this.fileTarget.value = ''
    if (files.length) this.select(files)
  }

  select(files) {
    this.stop()
    this.image = null
    this.clearFeedback()
    if (files.length !== 1) return this.fail('Choose one product image at a time.')

    const image = files[0]
    if (!image.size) return this.fail('The image is empty. Choose another image.')
    if (image.size > MAX_BYTES) return this.fail(ERRORS[413])
    if (!FORMATS.test(image.name)) return this.fail(ERRORS[415])

    this.image = image
    this.start()
  }

  edited() {
    if (!this.run) return

    this.stop()
    this.statusTarget.textContent = 'Image upload cancelled. Your edits are kept.'
    this.retryTarget.hidden = !this.image
  }

  cancel() {
    this.stop()
    this.statusTarget.textContent = 'Image upload cancelled.'
    this.retryTarget.hidden = !this.image
    this.textareaTarget.focus()
  }

  retry() {
    // Explicit user retry only: a failed POST may already have created a backend job.
    if (this.image && !this.run) {
      this.start()
      this.cancelTarget.focus()
    }
  }

  async start() {
    this.clearFeedback()
    const run = { abort: new AbortController(), original: this.textareaTarget.value }
    this.run = run
    this.cancelTarget.hidden = false
    this.statusTarget.textContent = 'Uploading image…'
    run.deadline = window.setTimeout(() => {
      if (this.run === run) this.fail('The image took too long to describe. Try again or enter a description.')
    }, 60000)

    const body = new FormData()
    body.append('image', this.image)
    try {
      const response = await fetch(this.urlValue, {
        method: 'POST', body, signal: run.abort.signal, credentials: 'same-origin',
        headers: { Accept: 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '' },
      })
      if (this.run !== run) return
      if (!response.ok) {
        const staleCsrf = response.status === 422 && !response.headers?.get('content-type')?.includes('application/json')
        if (!staleCsrf && [413, 415, 422].includes(response.status)) this.image = null
        return this.fail(staleCsrf ? ERRORS[403] : (ERRORS[response.status] || RECOVERY))
      }
      const payload = await response.json()
      if (this.run !== run) return

      const pollUrl = new URL(payload.poll_url, window.location.href)
      const uploadUrl = new URL(this.urlValue, window.location.href)
      if (response.status !== 202 || pollUrl.origin !== window.location.origin ||
          !pollUrl.pathname.startsWith(`${uploadUrl.pathname}/`) || !pollUrl.searchParams.get('token')) throw new Error(RECOVERY)

      run.url = pollUrl.href
      this.statusTarget.textContent = 'Image queued…'
      this.schedule(run)
    } catch (error) {
      if (this.run === run) this.fail(RECOVERY)
    }
  }

  schedule(run) {
    run.timer = window.setTimeout(() => this.poll(run), 1000)
  }

  async poll(run) {
    if (this.run !== run) return

    try {
      const response = await fetch(run.url, {
        signal: run.abort.signal, credentials: 'same-origin', cache: 'no-store', headers: { Accept: 'application/json' },
      })
      const payload = await response.json()
      if (this.run !== run) return
      if (!response.ok) throw new Error(RECOVERY)

      if (payload.status === 'completed') {
        if (typeof payload.description !== 'string' || !payload.description.trim() || payload.description.length > 1000 ||
            !Array.isArray(payload.uncertainties) || !payload.uncertainties.every(item => typeof item === 'string')) throw new Error(RECOVERY)
        if (this.textareaTarget.value !== run.original) {
          this.stop()
          this.statusTarget.textContent = 'Your edits are kept.'
          this.retryTarget.hidden = false
          return
        }
        const restoreFocus = document.activeElement === this.cancelTarget
        this.stop()
        this.textareaTarget.value = payload.description
        this.textareaTarget.dispatchEvent(new Event('input', { bubbles: true }))
        this.statusTarget.textContent = 'Check the description, then search.'
        this.image = null
        if (restoreFocus && !this.textareaTarget.disabled) this.textareaTarget.focus()
      } else if (['queued', 'running'].includes(payload.status)) {
        this.statusTarget.textContent = payload.status === 'running' ? 'Describing image…' : 'Image queued…'
        this.schedule(run)
      } else {
        throw new Error(RECOVERY)
      }
    } catch (error) {
      if (this.run === run) this.fail(RECOVERY)
    }
  }

  stop() {
    if (this.run) {
      window.clearTimeout(this.run.timer)
      window.clearTimeout(this.run.deadline)
      this.run.abort.abort()
      this.run = null
    }
    this.cancelTarget.hidden = true
  }

  interrupt() {
    if (!this.run) return

    this.stop()
    this.statusTarget.textContent = 'Image upload cancelled.'
    this.retryTarget.hidden = !this.image
  }

  clearFeedback() {
    this.errorTarget.hidden = true
    this.errorTarget.textContent = ''
    this.statusTarget.textContent = ''
    this.retryTarget.hidden = true
  }

  fail(message) {
    const restoreFocus = document.activeElement === this.cancelTarget || document.activeElement === this.retryTarget
    this.stop()
    this.statusTarget.textContent = ''
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
    this.retryTarget.hidden = !this.image
    if (restoreFocus) (this.image ? this.retryTarget : this.fileTarget).focus()
  }
}
