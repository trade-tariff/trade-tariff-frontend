import { Application } from '@hotwired/stimulus'
import GuidedSearchValidationController from '../../../app/javascript/controllers/guided_search_validation_controller'
import QueuedSearchController from '../../../app/javascript/controllers/queued_search_controller'
import InteractiveQuestionController from '../../../app/javascript/controllers/interactive_question_controller'
import { observationId } from '../../../app/javascript/src/guided-search-journey'

const ID = /^[a-zA-Z0-9-]{1,64}$/
const reply = (body, status = 200) => ({ ok: status >= 200 && status < 300, status, json: async () => body })

function events() {
  return window.fetch.mock.calls
    .filter(([, options]) => options?.body && String(options.body).includes('event_type'))
    .map(([, options]) => JSON.parse(options.body))
}

describe('guided search journey telemetry', () => {
  let application

  beforeEach(() => {
    document.head.innerHTML = '<meta name="csrf-token" content="csrf-token">'
    window.sessionStorage.clear()
    window.fetch = jest.fn().mockResolvedValue({ ok: true })
    window.scrollTo = jest.fn()
    jest.spyOn(HTMLFormElement.prototype, 'submit').mockImplementation(() => {})
  })

  afterEach(() => {
    application?.stop()
    jest.useRealTimers()
    jest.restoreAllMocks()
    delete window.fetch
  })

  async function startValidation(value = '') {
    document.body.innerHTML = `
      <form id="new_search" data-controller="guided-search-validation queued-search"
            data-guided-search-event-url="/search/guided-search-event"
            data-queued-search-url-value="/search/queued"
            data-action="submit->guided-search-validation#validateAndSubmit guided-search:submit->queued-search#submit">
        <div data-guided-search-validation-target="formContent">
          <div data-guided-search-validation-target="formGroup">
            <textarea id="search-q-field" data-guided-search-validation-target="textarea">${value}</textarea>
          </div>
          <input type="hidden" name="interactive_search" value="true" data-guided-search-validation-target="hiddenField">
        </div>
        <div data-queued-search-target="error" class="govuk-!-display-none" tabindex="-1">
          <p data-queued-search-target="message"></p>
        </div>
      </form>`
    application = Application.start()
    application.register('guided-search-validation', GuidedSearchValidationController)
    application.register('queued-search', QueuedSearchController)
    await Promise.resolve()
    document.querySelector('#new_search').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
  }

  it('counts an invalid initial submit before validation and does not enqueue', async () => {
    await startValidation('')

    expect(HTMLFormElement.prototype.submit).not.toHaveBeenCalled()
    expect(events().map(event => event.event_type)).toEqual(['initial_submitted', 'page_visible'])
    expect(events()[0].request_id).toMatch(ID)
    expect(events()[0].event_id).toMatch(ID)
    expect(events()[1]).toMatchObject({ event_type: 'page_visible', destination: 'input_error', request_id: events()[0].request_id })
    expect(document.querySelector('[name="request_id"]').value).toBe(events()[0].request_id)
  })

  it('gives a corrected initial submit a new request id', async () => {
    await startValidation('')
    const first = events()[0].request_id
    document.querySelector('#search-q-field').value = 'a'
    document.querySelector('#new_search').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))

    const initial = events().filter(event => event.event_type === 'initial_submitted')
    expect(initial).toHaveLength(2)
    expect(initial[1].request_id).not.toBe(first)
  })

  it('keeps search working when storage and the event request fail', async () => {
    jest.spyOn(Storage.prototype, 'getItem').mockImplementation(() => { throw new Error('blocked') })
    jest.spyOn(Storage.prototype, 'setItem').mockImplementation(() => { throw new Error('blocked') })
    window.fetch.mockRejectedValue(new Error('offline'))

    await expect(startValidation('')).resolves.toBeUndefined()

    expect(document.querySelector('.govuk-error-summary').textContent).toContain('Enter a search term')
    expect(HTMLFormElement.prototype.submit).not.toHaveBeenCalled()
  })

  it('records queue recovery after the error is visible and does not start another journey', async () => {
    jest.useFakeTimers()
    window.fetch.mockResolvedValue(reply({ error: 'nope' }, 503))
    jest.spyOn(Storage.prototype, 'removeItem').mockImplementation(() => { throw new Error('blocked') })
    await startValidation('horse')
    await jest.advanceTimersByTimeAsync(0)

    const error = document.querySelector('[data-queued-search-target="error"]')
    expect(error.classList.contains('govuk-!-display-none')).toBe(false)
    const recorded = events()
    expect(recorded.filter(event => event.event_type === 'initial_submitted')).toHaveLength(1)
    expect(recorded.at(-1)).toMatchObject({
      event_type: 'page_visible',
      destination: 'backend_error',
      request_id: recorded[0].request_id,
    })
    expect(HTMLFormElement.prototype.submit).not.toHaveBeenCalled()

    const form = document.querySelector('#new_search')
    form.querySelector('[name="telemetry_submission_id"]').value = 'later-question-submission'
    const controller = application.getControllerForElementAndIdentifier(form, 'queued-search')
    const laterRun = { form, controller: new AbortController() }
    controller.run = laterRun
    controller.fail(laterRun)
    const laterRecovery = events().at(-1)
    expect(laterRecovery.request_id).toBe(recorded.at(-1).request_id)
    expect(laterRecovery.event_id).not.toBe(recorded.at(-1).event_id)
  })

  it('does not emit another initial submit when the queue hands off', async () => {
    jest.useFakeTimers()
    const accepted = {
      id: '2be1e438-1c16-42c0-8517-405b1d4f1caf',
      token: 'signed-grant',
      request_id: 'request-123',
      date: { year: 2026, month: 1, day: 2 },
      poll_url: '/search/queued/2be1e438-1c16-42c0-8517-405b1d4f1caf?token=signed-grant',
    }
    window.fetch.mockImplementation(async (url, options) => {
      if (String(url).includes('guided-search-event')) return { ok: true }
      if (options?.method === 'POST') return reply({ ...accepted, request_id: options.body.get('request_id') }, 202)
      return reply({ status: 'completed' })
    })
    await startValidation('horse')
    await jest.advanceTimersByTimeAsync(250)

    expect(HTMLFormElement.prototype.submit).toHaveBeenCalledTimes(1)
    expect(events().filter(event => event.event_type === 'initial_submitted')).toHaveLength(1)
    expect(document.querySelector('[name="request_id"]').value).toBe(events()[0].request_id)
  })

  it('keeps one question id across dont know, back, and a normal answer', async () => {
    document.body.innerHTML = `
      <div data-controller="interactive-question"
           data-interactive-question-event-url-value="/search/guided-search-event"
           data-interactive-question-request-id-value="request-123"
           data-interactive-question-question-id-value="question-server-id"
           data-interactive-question-question-number-value="2">
        <form data-action="submit->interactive-question#submitWithThinking">
          <input type="hidden" name="request_id" value="request-123">
          <input type="hidden" name="telemetry_question_id" value="question-server-id">
          <input type="radio" id="known" name="interactive_search_form[answer]" value="Haddock" data-guided-option="true">
          <input type="radio" id="unknown" name="interactive_search_form[answer]" value="I don't know">
        </form>
        <div data-interactive-question-target="dontKnow" class="govuk-!-display-none"></div>
        <button data-action="interactive-question#goBack">Go back</button>
      </div>`
    application = Application.start()
    application.register('interactive-question', InteractiveQuestionController)
    await Promise.resolve()
    const form = document.querySelector('form')
    document.querySelector('#unknown').checked = true
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
    document.querySelector('[data-action="interactive-question#goBack"]').click()
    document.querySelector('#unknown').checked = false
    document.querySelector('#known').checked = true
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))

    const [dontKnow, answer] = events()
    expect(dontKnow).toMatchObject({
      event_type: 'dont_know', question_response: 'dont_know', terminal_outcome: 'dont_know', request_id: 'request-123',
    })
    expect(answer).toMatchObject({
      event_type: 'answer_submitted', response_source: 'browser_selected', question_response: 'browser_selected', request_id: 'request-123',
    })
    expect(dontKnow.question_id).toBe('question-server-id')
    expect(answer.question_id).toBe('question-server-id')
    expect(dontKnow.submission_id).not.toBe(answer.submission_id)
    expect(JSON.stringify(events())).not.toContain('Haddock')
    expect(form.querySelector('[name="telemetry_question_id"]').value).toBe('question-server-id')

    document.querySelector('[data-action="interactive-question#goBack"]').click()
    document.querySelector('#unknown').checked = true
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
    const laterDontKnow = events().at(-1)
    expect(laterDontKnow.question_id).toBe(dontKnow.question_id)
    expect(laterDontKnow.event_id).not.toBe(dontKnow.event_id)
    expect(laterDontKnow.submission_id).not.toBe(dontKnow.submission_id)
  })

  it('does not record an answer when no rendered option is selected', async () => {
    document.body.innerHTML = `
      <div data-controller="interactive-question"
           data-interactive-question-event-url-value="/search/guided-search-event"
           data-interactive-question-question-id-value="question-server-id">
        <form data-action="submit->interactive-question#submitWithThinking">
          <input type="radio" id="injected" name="interactive_search_form[answer]" value="Not an option" checked>
        </form>
      </div>`
    application = Application.start()
    application.register('interactive-question', InteractiveQuestionController)
    await Promise.resolve()
    document.querySelector('form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))

    expect(events().map(event => event.event_type)).not.toContain('answer_submitted')
  })

  it('reuses an observation id when the same logical event is sent again', () => {
    const original = observationId('page_visible:results:request-123')
    expect(observationId('page_visible:results:request-123')).toBe(original)
    expect(observationId('page_visible:results:request-456')).not.toBe(original)
  })
})
