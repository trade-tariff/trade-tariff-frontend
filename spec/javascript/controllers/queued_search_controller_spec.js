import { Application } from '@hotwired/stimulus'
import QueuedSearchController from '../../../app/javascript/controllers/queued_search_controller'
import GuidedSearchValidationController from '../../../app/javascript/controllers/guided_search_validation_controller'
import SearchModeController from '../../../app/javascript/controllers/search_mode_controller'
import InteractiveQuestionController from '../../../app/javascript/controllers/interactive_question_controller'
import InteractiveSearchRadioController from '../../../app/javascript/controllers/interactive_search_radio_controller'

const reply = (body, status = 200) => ({ ok: status >= 200 && status < 300, status, json: async () => body })
const queuedId = '2be1e438-1c16-42c0-8517-405b1d4f1caf'

describe('QueuedSearchController', () => {
  let application, form, submit, error

  beforeEach(async () => {
    document.head.innerHTML = '<meta name="csrf-token" content="test-token">'
    document.body.innerHTML = `
      <form data-controller="queued-search" data-action="guided-search:submit->queued-search#submit"
            data-queued-search-url-value="/search/queued">
        <input name="q" value="horse">
        <input name="interactive_search" value="true">
        <div data-queued-search-target="error" class="govuk-!-display-none" tabindex="-1">
          <p data-queued-search-target="message"></p>
        </div>
      </form>`
    application = Application.start()
    application.register('queued-search', QueuedSearchController)
    await new Promise(resolve => setTimeout(resolve, 0))
    form = document.querySelector('form')
    error = jest.fn()
    form.addEventListener('queued-search:error', error)
    submit = jest.spyOn(HTMLFormElement.prototype, 'submit').mockImplementation(() => {})
    window.fetch = jest.fn()
    jest.useFakeTimers()
  })

  afterEach(() => {
    document.querySelectorAll('[data-controller]').forEach(element => {
      element.dataset.controller.split(' ').forEach(identifier => {
        application.getControllerForElementAndIdentifier(element, identifier)?.disconnect()
      })
    })
    window.sessionStorage.clear()
    document.cookie = 'interactive_search=; Max-Age=0; path=/'
    application.stop()
    document.body.innerHTML = ''
    jest.useRealTimers()
    jest.restoreAllMocks()
    delete window.fetch
  })

  function start() {
    form.dispatchEvent(new CustomEvent('guided-search:submit', { bubbles: true, cancelable: true, detail: { form } }))
  }

  function accepted(overrides = {}) {
    const body = { id: queuedId, token: 'signed-grant', request_id: 'journey-id', date: { year: 2025, month: 1, day: 2 }, ...overrides }
    return reply({ ...body, poll_url: `/search/queued/${body.id}?token=${encodeURIComponent(body.token)}` }, 202)
  }

  it.each([undefined, null, '', '   ', 123, true, {}, []])('rejects acceptance with an invalid token (%p) without polling or fallback', async token => {
    window.fetch.mockResolvedValueOnce(accepted({ token }))
    start()
    await jest.advanceTimersByTimeAsync(120000)

    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(error).toHaveBeenCalledTimes(1)
    expect(submit).not.toHaveBeenCalled()
    expect(form.elements.queued_search_token).toBeUndefined()
  })

  it('polls until complete then hands off the queued id and accepted token', async () => {
    window.fetch.mockResolvedValueOnce(accepted())
      .mockResolvedValueOnce(reply({ status: 'queued' }))
      .mockResolvedValueOnce(reply({ status: 'running' }))
      .mockResolvedValueOnce(reply({ status: 'completed' }))
    start()
    await jest.advanceTimersByTimeAsync(250)
    expect(submit).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(750)
    expect(submit).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(4000)
    expect(submit).toHaveBeenCalledTimes(1)
    expect(form.elements.queued_search_id.value).toBe(queuedId)
    expect(form.elements.queued_search_token.type).toBe('hidden')
    expect(form.elements.queued_search_token.value).toBe('signed-grant')
    expect(window.fetch.mock.calls.slice(1).map(([url]) => url)).toEqual(Array(3).fill(`http://localhost/search/queued/${queuedId}?token=signed-grant`))
    expect(form.elements.request_id.value).toBe('journey-id')
    expect(form.elements.year.value).toBe('2025')
    expect(form.elements.month.value).toBe('1')
    expect(form.elements.day.value).toBe('2')
    expect(window.fetch.mock.calls[0][1].headers['X-CSRF-Token']).toBe('test-token')
    expect(window.fetch.mock.calls[0][1].body.get('q')).toBe('horse')
  })

  it.each([undefined, null, 'invalid', {}, { year: 2025, month: 1 }, { year: '2025', month: 1, day: 2 }])('rejects malformed acceptance dates (%p)', async date => {
    const response = accepted()
    const payload = await response.json()
    window.fetch.mockResolvedValue(reply({ ...payload, date }, 202))
    start()
    await jest.advanceTimersByTimeAsync(1000)

    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(error).toHaveBeenCalledTimes(1)
    expect(submit).not.toHaveBeenCalled()
  })

  it('pins blank nested Rails date fields for handoff and restores them on back navigation', async () => {
    form.insertAdjacentHTML('beforeend', `
      <input name="search[as_of(1i)]" value="">
      <input name="search[as_of(2i)]" value="">
      <input name="search[as_of(3i)]" value="">`)
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValue(reply({ status: 'completed' }))
    start()
    await jest.advanceTimersByTimeAsync(250)
    expect(form.elements['search[as_of(1i)]'].value).toBe('2025')
    expect(form.elements['search[as_of(2i)]'].value).toBe('1')
    expect(form.elements['search[as_of(3i)]'].value).toBe('2')

    const event = new Event('pageshow')
    Object.defineProperty(event, 'persisted', { value: true })
    window.dispatchEvent(event)
    for (const part of [1, 2, 3]) {
      expect(form.elements[`search[as_of(${part}i)]`].value).toBe('')
      expect(form.elements[`search[as_of(${part}i)]`].type).toBe('text')
    }
  })

  it('uses elapsed-time slots and continues checking the long tail', async () => {
    const polls = []
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementation(async () => {
      polls.push(performance.now())
      return reply({ status: 'running' })
    })
    start()
    await jest.advanceTimersByTimeAsync(1000)
    jest.setSystemTime(Date.now() + 3600000)
    await jest.advanceTimersByTimeAsync(24000)

    expect(polls).toEqual([250, 1000, 5000, 7000, 10000, 12000, 15000, 20000, 25000])
    expect(submit).not.toHaveBeenCalled()
  })

  it('checks once immediately after slow acceptance, without restarting the schedule', async () => {
    const polls = []
    window.fetch.mockImplementationOnce(() => new Promise(resolve => setTimeout(() => resolve(accepted()), 2700)))
      .mockImplementation(async () => {
        polls.push(performance.now())
        return reply({ status: 'queued' })
      })
    start()
    await jest.advanceTimersByTimeAsync(7000)

    expect(polls).toEqual([2700, 5000, 7000])
  })

  it('skips missed slots after a slow poll instead of sending catch-up requests', async () => {
    const polls = []
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementation(() => {
      polls.push(performance.now())
      if (polls.length === 1) {
        return new Promise(resolve => setTimeout(() => resolve(reply({ status: 'running' })), 6000))
      }
      return Promise.resolve(reply({ status: 'running' }))
    })
    start()
    await jest.advanceTimersByTimeAsync(12000)

    expect(polls).toEqual([250, 7000, 10000, 12000])
  })

  it('returns to the original slots after a transient error recovers', async () => {
    const polls = []
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementation(async () => {
      polls.push(performance.now())
      return polls.length === 1 ? reply({}, 503) : reply({ status: 'running' })
    })
    start()
    await jest.advanceTimersByTimeAsync(7000)

    expect(polls).toEqual([250, 2250, 5000, 7000])
  })

  it('stops at the submission deadline without starting a final poll', async () => {
    const polls = []
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementation(async () => {
      polls.push(performance.now())
      return reply({ status: 'running' })
    })
    start()
    await jest.advanceTimersByTimeAsync(119999)
    expect(polls.at(-1)).toBe(115000)
    expect(error).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(1)
    expect(error).toHaveBeenCalledTimes(1)
    expect(polls.at(-1)).toBe(115000)
    expect(submit).not.toHaveBeenCalled()
  })

  it('does not fetch when an overdue timer resumes after the deadline', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValue(reply({ status: 'running' }))
    start()
    await jest.advanceTimersByTimeAsync(0)
    jest.spyOn(performance, 'now').mockReturnValue(120001)
    await jest.advanceTimersByTimeAsync(250)

    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(error).toHaveBeenCalledTimes(1)
  })

  it('prevents duplicate submissions and overlapping polls', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementation(() => new Promise(() => {}))
    start()
    start()
    await jest.advanceTimersByTimeAsync(3000)
    expect(window.fetch).toHaveBeenCalledTimes(2)
    expect(submit).not.toHaveBeenCalled()
  })

  it.each(['failed', 'unexpected'])('restores the form on %s without resubmitting', async status => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status }))
    start()
    await jest.advanceTimersByTimeAsync(250)
    expect(error).toHaveBeenCalledTimes(1)
    expect(document.activeElement).toBe(form.querySelector('[data-queued-search-target="error"]'))
    expect(form.elements.q.value).toBe('horse')
    expect(submit).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(10000)
    expect(window.fetch).toHaveBeenCalledTimes(2)
  })

  it('does not retry an ambiguous submission failure', async () => {
    window.fetch.mockRejectedValue(new Error('network error'))
    start()
    await jest.advanceTimersByTimeAsync(10000)
    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(error).toHaveBeenCalledTimes(1)
    expect(submit).not.toHaveBeenCalled()
  })

  it('uses the normal Rails validation response only when nothing was queued', async () => {
    window.fetch.mockResolvedValue(reply({ error: 'Invalid date', validation_failed: true }, 422))
    start()
    await jest.advanceTimersByTimeAsync(0)
    expect(submit).toHaveBeenCalledTimes(1)
    expect(form.elements.queued_search_id).toBeUndefined()
    expect(window.fetch).toHaveBeenCalledTimes(1)
  })

  it('does not fall back to synchronous search for an unrecognised 422', async () => {
    window.fetch.mockResolvedValue(reply({}, 422))
    start()
    await jest.advanceTimersByTimeAsync(0)
    expect(submit).not.toHaveBeenCalled()
    expect(error).toHaveBeenCalledTimes(1)
  })

  it('stops on expiry', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({}, 404))
    start()
    await jest.advanceTimersByTimeAsync(10000)
    expect(error).toHaveBeenCalledTimes(1)
    expect(window.fetch).toHaveBeenCalledTimes(2)
  })

  it('bounds waiting even when fetch hangs', async () => {
    application.getControllerForElementAndIdentifier(form, 'queued-search').deadlineValue = 5000
    window.fetch.mockImplementation(() => new Promise(() => {}))
    start()
    await jest.advanceTimersByTimeAsync(5000)
    expect(window.fetch.mock.calls[0][1].signal.aborted).toBe(true)
    expect(error).toHaveBeenCalledTimes(1)
    expect(submit).not.toHaveBeenCalled()
  })

  it('cancels on pagehide and ignores late responses', async () => {
    let finish
    window.fetch.mockImplementation(() => new Promise(resolve => { finish = resolve }))
    start()
    window.dispatchEvent(new Event('pagehide'))
    finish(accepted())
    await jest.advanceTimersByTimeAsync(10000)
    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(submit).not.toHaveBeenCalled()
    expect(error).not.toHaveBeenCalled()
  })

  it('restores injected handoff fields on back navigation so dates can be changed', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'completed' }))
    start()
    await jest.advanceTimersByTimeAsync(250)
    expect(form.elements.year.value).toBe('2025')

    const event = new Event('pageshow')
    Object.defineProperty(event, 'persisted', { value: true })
    window.dispatchEvent(event)
    expect(form.elements.year).toBeUndefined()
    expect(form.elements.queued_search_id).toBeUndefined()
    expect(form.elements.queued_search_token).toBeUndefined()
    expect(form.elements.request_id).toBeUndefined()
  })

  it('restores a pre-existing token field on back navigation and can queue again', async () => {
    form.insertAdjacentHTML('beforeend', '<input name="queued_search_token" value="previous-grant">')
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'completed', token: 'untrusted-status-token' }))
      .mockResolvedValueOnce(accepted({ token: 'new-grant' })).mockResolvedValueOnce(reply({ status: 'completed' }))
    start()
    await jest.advanceTimersByTimeAsync(250)
    expect(form.elements.queued_search_token.value).toBe('signed-grant')
    expect(form.querySelectorAll('[name="queued_search_token"]')).toHaveLength(1)

    window.dispatchEvent(new Event('pagehide'))
    window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: true }))
    expect(form.elements.queued_search_token.value).toBe('previous-grant')
    expect(form.elements.queued_search_token.type).toBe('text')

    start()
    await jest.advanceTimersByTimeAsync(250)
    expect(submit).toHaveBeenCalledTimes(2)
    expect(form.elements.queued_search_token.value).toBe('new-grant')
  })

  it('ignores an old response after returning and starting another search', async () => {
    let finish
    window.fetch.mockImplementationOnce(() => new Promise(resolve => { finish = resolve }))
      .mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'completed' }))
    start()
    window.dispatchEvent(new Event('pagehide'))
    start()
    finish(accepted())
    await jest.advanceTimersByTimeAsync(250)
    expect(submit).toHaveBeenCalledTimes(1)
    expect(window.fetch).toHaveBeenCalledTimes(3)
  })

  it('keeps one throbber through polls and shows recovery with the revised form controllers', async () => {
    application.register('guided-search-validation', GuidedSearchValidationController)
    application.register('search-mode', SearchModeController)
    window.scrollTo = jest.fn()
    document.body.innerHTML = `
      <section data-guided-search-validation-page-content>
        <form data-controller="search-mode guided-search-validation queued-search"
              data-search-mode-initial-mode-value="guided" data-queued-search-url-value="/search/queued"
              data-action="submit->guided-search-validation#validateAndSubmit guided-search:submit->queued-search#submit queued-search:error->guided-search-validation#restore">
          <div data-guided-search-validation-target="formContent">
            <div data-search-mode-target="tabs"></div>
            <div data-search-mode-target="keywordSection"></div>
            <div data-search-mode-target="guidedSection">
              <div data-guided-search-validation-target="formGroup">
                <textarea id="query" name="q" data-guided-search-validation-target="textarea">horse</textarea>
              </div>
            </div>
            <input name="interactive_search" data-search-mode-target="hiddenField" data-guided-search-validation-target="hiddenField">
            <div class="govuk-error-summary govuk-!-display-none" data-queued-search-target="error" data-search-mode-error="guided" tabindex="-1">
              <p data-queued-search-target="message"></p>
            </div>
          </div>
        </form>
      </section>
      <section class="govuk-!-display-none" data-guided-search-validation-loading-page>Collecting information...</section>`
    await jest.advanceTimersByTimeAsync(0)
    form = document.querySelector('form')
    const loading = document.querySelector('[data-guided-search-validation-loading-page]')
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'queued' }))
      .mockResolvedValueOnce(reply({ status: 'running' })).mockResolvedValueOnce(reply({ status: 'failed' }))
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
    await jest.advanceTimersByTimeAsync(0)
    expect(loading.classList.contains('govuk-!-display-none')).toBe(false)
    await jest.advanceTimersByTimeAsync(1000)
    expect(document.querySelector('[data-guided-search-validation-loading-page]')).toBe(loading)
    expect(loading.classList.contains('govuk-!-display-none')).toBe(false)
    expect(submit).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(4000)
    const summary = form.querySelector('[data-queued-search-target="error"]')
    expect(summary.hidden).toBe(false)
    expect(summary.classList.contains('govuk-!-display-none')).toBe(false)
    expect(document.activeElement).toBe(summary)
    expect(loading.classList.contains('govuk-!-display-none')).toBe(true)
    expect(form.elements.q.value).toBe('horse')
  })

  it.each(['question', 'shared initial form'])('restores the %s and queues exactly one user retry with the original input', async journey => {
    application.register('interactive-question', InteractiveQuestionController)
    application.register('guided-search-validation', GuidedSearchValidationController)
    application.register('interactive-search-radio', InteractiveSearchRadioController)
    window.scrollTo = jest.fn()
    const summaryMarkup = `<div data-queued-search-target="error" class="govuk-!-display-none" tabindex="-1">
      <p data-queued-search-target="message"></p>
    </div>`
    document.body.innerHTML = journey === 'question' ? `
      <div data-controller="interactive-question queued-search" data-queued-search-url-value="/search/queued"
           data-action="guided-search:submit->queued-search#submit queued-search:error->interactive-question#restore">
        <h1 data-interactive-question-target="header">Search for a commodity</h1>
        <div data-interactive-question-target="form" data-test-content>
          ${summaryMarkup}
          <form data-action="submit->interactive-question#submitWithThinking">
            <input name="q" value="horse">
            <input name="interactive_search" value="true">
            <input type="radio" name="interactive_search_form[answer]" value="Pure-bred" checked>
            <input type="radio" name="interactive_search_form[answer]" value="Other">
            <button type="submit">Submit</button>
          </form>
        </div>
        <div data-interactive-question-target="thinking" data-test-loading class="govuk-!-display-none">Thinking...</div>
      </div>` : `
      <section data-guided-search-validation-page-content data-test-content>
        <form data-controller="interactive-search-radio guided-search-validation queued-search"
              data-queued-search-url-value="/search/queued"
              data-action="submit->guided-search-validation#validateAndSubmit guided-search:submit->queued-search#submit queued-search:error->guided-search-validation#restore">
          <div data-guided-search-validation-target="formContent">
            ${summaryMarkup}
            <input type="radio" name="mode" value="keyword" data-interactive-search-radio-target="toggle"
                   data-action="change->interactive-search-radio#toggle">
            <input type="radio" name="mode" value="guided" data-interactive-search-radio-target="toggle"
                   data-action="change->interactive-search-radio#toggle">
            <input name="interactive_search" data-interactive-search-radio-target="hiddenField" data-guided-search-validation-target="hiddenField">
            <div data-interactive-search-radio-target="keywordSection"><input id="q" name="q" value="unused keyword"></div>
            <div data-interactive-search-radio-target="guidedSection">
              <div data-guided-search-validation-target="formGroup">
                <textarea id="query" name="q" data-interactive-search-radio-target="guidedInput" data-guided-search-validation-target="textarea">horse</textarea>
              </div>
            </div>
            <button type="submit">Search</button>
          </div>
        </form>
      </section>
      <section data-guided-search-validation-loading-page data-test-loading class="govuk-!-display-none">Collecting information...</section>`
    await jest.advanceTimersByTimeAsync(0)
    form = document.querySelector('form')
    if (journey === 'shared initial form') {
      const guided = form.querySelector('[value="guided"]')
      guided.checked = true
      guided.dispatchEvent(new Event('change', { bubbles: true }))
    }
    const content = document.querySelector('[data-test-content]')
    const loading = document.querySelector('[data-test-loading]')
    const summary = document.querySelector('[data-queued-search-target="error"]')
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'failed' }))
      .mockResolvedValueOnce(accepted({ token: 'retry-grant' })).mockResolvedValueOnce(reply({ status: 'completed' }))

    form.querySelector('button').click()
    await jest.advanceTimersByTimeAsync(0)
    expect(loading.classList.contains('govuk-!-display-none')).toBe(false)
    expect(content.classList.contains('govuk-!-display-none')).toBe(true)
    await jest.advanceTimersByTimeAsync(250)

    expect(loading.classList.contains('govuk-!-display-none')).toBe(true)
    expect(content.classList.contains('govuk-!-display-none')).toBe(false)
    expect(summary.classList.contains('govuk-!-display-none')).toBe(false)
    expect(summary.getAttribute('role')).toBe('alert')
    expect(summary.textContent).toContain('Please try your search again')
    expect(document.activeElement).toBe(summary)
    expect(window.sessionStorage.getItem('guidedSearchSubmittedAt')).toBeNull()
    expect(new FormData(form).getAll('q')).toEqual(['horse'])
    const selected = form.querySelector('input[type="radio"]:checked')
    expect(selected.value).toBe(journey === 'question' ? 'Pure-bred' : 'guided')
    expect(submit).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(10000)
    expect(window.fetch).toHaveBeenCalledTimes(2)

    form.querySelector('button').click()
    await jest.advanceTimersByTimeAsync(0)
    expect(summary.classList.contains('govuk-!-display-none')).toBe(true)
    expect(loading.classList.contains('govuk-!-display-none')).toBe(false)
    expect(submit).not.toHaveBeenCalled()
    const submissions = window.fetch.mock.calls.filter(([, options]) => options.method === 'POST')
    expect(submissions).toHaveLength(2)
    submissions.forEach(([, options]) => {
      expect(options.body.getAll('q')).toEqual(['horse'])
      expect(options.body.get('interactive_search')).toBe('true')
      expect(options.body.get(selected.name)).toBe(selected.value)
    })
    await jest.advanceTimersByTimeAsync(250)
    expect(submit).toHaveBeenCalledTimes(1)
    expect(form.elements.queued_search_token.value).toBe('retry-grant')
    expect(window.fetch).toHaveBeenCalledTimes(4)
  })

  it('stops after three consecutive polling failures without retrying the submission', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValue(reply({}, 503))
    start()
    await jest.advanceTimersByTimeAsync(6249)
    expect(error).not.toHaveBeenCalled()
    await jest.advanceTimersByTimeAsync(1)
    expect(error).toHaveBeenCalledTimes(1)
    await jest.advanceTimersByTimeAsync(120000)
    expect(window.fetch).toHaveBeenCalledTimes(4)
    expect(window.fetch.mock.calls.filter(([, options]) => options.method === 'POST')).toHaveLength(1)
    expect(submit).not.toHaveBeenCalled()
  })

  it('resets consecutive failures after a successful pending response', async () => {
    window.fetch.mockResolvedValueOnce(accepted())
      .mockResolvedValueOnce(reply({}, 503)).mockRejectedValueOnce(new Error('network error'))
      .mockResolvedValueOnce(reply({ status: 'running' }))
      .mockResolvedValueOnce(reply({}, 503)).mockRejectedValueOnce(new Error('network error'))
      .mockResolvedValueOnce(reply({ status: 'completed' }))
    start()
    await jest.advanceTimersByTimeAsync(13000)

    expect(error).not.toHaveBeenCalled()
    expect(submit).toHaveBeenCalledTimes(1)
    expect(window.fetch).toHaveBeenCalledTimes(7)
  })

  it.each(['submission', 'poll'])('recovers from redirected %s responses without handing off or synchronous fallback', async phase => {
    const redirected = { ...reply({ status: 'completed' }), redirected: true }
    if (phase === 'poll') window.fetch.mockResolvedValueOnce(accepted())
    window.fetch.mockResolvedValue(redirected)
    start()
    await jest.advanceTimersByTimeAsync(120000)

    expect(error).toHaveBeenCalledTimes(1)
    expect(submit).not.toHaveBeenCalled()
    expect(window.fetch).toHaveBeenCalledTimes(phase === 'submission' ? 1 : 4)
    expect(window.fetch.mock.calls.filter(([, options]) => options.method === 'POST')).toHaveLength(1)
    expect(form.elements.queued_search_token).toBeUndefined()
  })

  it('retries transient polling failures, not submissions', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({}, 503))
      .mockResolvedValueOnce(reply({ status: 'completed' }))
    start()
    await jest.advanceTimersByTimeAsync(2250)
    expect(submit).toHaveBeenCalledTimes(1)
    expect(window.fetch.mock.calls.filter(([, options]) => options.method === 'POST')).toHaveLength(1)
  })
})
