import { Controller } from '@hotwired/stimulus'

const RECOVERY_MESSAGE = 'We could not complete this search. Please try your search again.'
// Data-informed starting cadence from AI-1093, not a fixed latency guarantee.
// Reduce status traffic through both web tiers; revisit as timings change.
// Evidence and trade-offs: docs/architecture/queued-guided-search.md.
const POLL_TIMES = [250, 1000, 5000, 7000, 10000, 12000, 15000]
const TAIL_POLL_INTERVAL = 5000

export default class extends Controller {
  static targets = ['error', 'message']
  static values = { url: String, deadline: { type: Number, default: 120000 } }

  connect() {
    this.onFormSubmit = () => this.clearError()
    this.element.addEventListener('submit', this.onFormSubmit, true)
    this.onPageHide = () => this.stop()
    this.onPageShow = event => {
      if (event.persisted) {
        this.submitted = false
        for (const { input, original } of this.handoffFields || []) {
          if (original) {
            input.value = original.value
            input.type = original.type
          } else {
            input.remove()
          }
        }
        this.handoffFields = []
      }
    }
    window.addEventListener('pagehide', this.onPageHide)
    window.addEventListener('pageshow', this.onPageShow)
  }

  disconnect() {
    this.stop()
    this.element.removeEventListener('submit', this.onFormSubmit, true)
    window.removeEventListener('pagehide', this.onPageHide)
    window.removeEventListener('pageshow', this.onPageShow)
  }

  async submit(event) {
    event.preventDefault()
    if (this.run || this.submitted) return

    this.clearError()
    const run = { form: event.detail.form, controller: new AbortController(), failures: 0, startedAt: performance.now() }
    this.run = run
    run.deadline = window.setTimeout(() => this.fail(run), this.deadlineValue)
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const accepted = await this.request(this.urlValue, run, {
        method: 'POST', body: new FormData(run.form), headers: { 'X-CSRF-Token': csrfToken },
      })
      if (this.run !== run) return
      const validIdentifiers = ['id', 'request_id', 'poll_url', 'token'].every(key =>
        typeof accepted[key] === 'string' && accepted[key].trim())
      const validDate = ['year', 'month', 'day'].every(part => Number.isInteger(accepted.date?.[part]))
      if (!validIdentifiers || !validDate) throw new Error('Invalid submission response')
      const pollUrl = new URL(accepted.poll_url, window.location.href)
      if (pollUrl.origin !== window.location.origin) throw new Error('Invalid polling URL')

      run.id = accepted.id
      run.token = accepted.token
      run.requestId = accepted.request_id
      run.date = accepted.date
      run.pollUrl = pollUrl.href
      this.schedulePoll(run, true)
    } catch (error) {
      if (this.run !== run) return
      if (error.validationFailed) {
        // Nothing was queued. Let Rails render its existing field errors.
        this.submitted = true
        this.stop()
        HTMLFormElement.prototype.submit.call(run.form)
      } else {
        this.fail(run, error.userMessage)
      }
    }
  }

  schedulePoll(run, first = false) {
    const elapsed = performance.now() - run.startedAt
    // A late acceptance gets one immediate check; subsequent checks skip missed slots.
    if (first && elapsed >= POLL_TIMES[0]) return this.poll(run)

    const next = (first ? POLL_TIMES[0] : POLL_TIMES.find(time => time > elapsed)) ??
      (Math.floor(elapsed / TAIL_POLL_INTERVAL) + 1) * TAIL_POLL_INTERVAL
    if (next >= this.deadlineValue) return

    run.timer = window.setTimeout(() => this.poll(run), Math.max(0, next - elapsed))
  }

  async poll(run) {
    if (this.run !== run) return
    if (performance.now() - run.startedAt >= this.deadlineValue) return this.fail(run)
    try {
      const payload = await this.request(run.pollUrl, run)
      if (this.run !== run) return
      run.failures = 0
      if (payload.status === 'completed') {
        this.handoffFields = []
        this.setHidden(run.form, 'request_id', run.requestId)
        this.setHidden(run.form, 'queued_search_id', run.id)
        this.setHidden(run.form, 'queued_search_token', run.token)
        for (const [index, part] of ['year', 'month', 'day'].entries()) {
          this.setHidden(run.form, part, run.date[part])
          const nestedField = `search[as_of(${index + 1}i)]`
          if (run.form.elements.namedItem(nestedField)) this.setHidden(run.form, nestedField, run.date[part])
        }
        this.submitted = true
        this.stop()
        HTMLFormElement.prototype.submit.call(run.form)
      } else if (['queued', 'running'].includes(payload.status)) {
        this.schedulePoll(run)
      } else {
        this.fail(run)
      }
    } catch (error) {
      if (this.run !== run) return
      run.failures += 1
      if ((error.status >= 400 && error.status < 500) || run.failures >= 3) {
        this.fail(run)
      } else {
        run.timer = window.setTimeout(() => this.poll(run), Math.min(1000 * 2 ** run.failures, 4000))
      }
    }
  }

  async request(url, run, options = {}) {
    const response = await window.fetch(url, {
      ...options, credentials: 'same-origin', signal: run.controller.signal,
      headers: { Accept: 'application/json', ...options.headers },
    })
    if (response.redirected) throw new Error('Session changed')
    if (!response.ok) {
      const error = new Error('Queued search request failed')
      error.status = response.status
      if (response.status === 422) {
        const payload = await response.json()
        if (typeof payload.error === 'string') error.userMessage = payload.error
        error.validationFailed = payload.validation_failed === true
      }
      throw error
    }
    return response.json()
  }

  fail(run, message = RECOVERY_MESSAGE) {
    if (this.run !== run) return
    this.stop()
    window.sessionStorage.removeItem('guidedSearchSubmittedAt')
    this.dispatch('error')
    this.messageTarget.textContent = message
    this.errorTarget.setAttribute('role', 'alert')
    this.errorTarget.classList.add('govuk-error-summary')
    this.errorTarget.classList.remove('govuk-!-display-none')
    this.errorTarget.focus()
  }

  clearError() {
    this.errorTarget.classList.add('govuk-!-display-none')
    this.errorTarget.classList.remove('govuk-error-summary')
    this.errorTarget.removeAttribute('role')
  }

  stop() {
    if (!this.run) return
    const run = this.run
    this.run = null
    window.clearTimeout(run.timer)
    window.clearTimeout(run.deadline)
    run.controller.abort()
  }

  setHidden(form, name, value) {
    const input = form.querySelector(`input[name="${name}"]`) || document.createElement('input')
    this.handoffFields.push({ input, original: input.parentNode ? { value: input.value, type: input.type } : null })
    input.type = 'hidden'
    input.name = name
    input.value = value
    if (!input.parentNode) form.appendChild(input)
  }
}
