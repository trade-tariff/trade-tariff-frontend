import { readFileSync } from 'node:fs'
import { Application } from '@hotwired/stimulus'
import GuidedSearchLoadingController from '../../../app/javascript/controllers/guided_search_loading_controller'

const panelMarkup = readFileSync(`${__dirname}/../../../app/views/search/_interactive_search_thinking.html.erb`, 'utf8')
const messages = [
  { text: 'Searching tariff references', description: 'Common product names.', min_seconds: 1, max_seconds: 3 },
  { text: 'Consulting chapter notes', description: 'Distinguishing similar products.', min_seconds: 2, max_seconds: 4 },
  { text: 'Preparing possible matches', description: 'Bringing information together.', min_seconds: 1, max_seconds: 2 },
]

describe('GuidedSearchLoadingController', () => {
  let application, panel, status, controller, form

  beforeEach(async () => {
    document.body.innerHTML = `<form></form>${panelMarkup}`
    panel = document.querySelector('[data-controller="guided-search-loading"]')
    // Rails renders this attribute from YAML. Use distinct fixture messages and
    // ranges here to prove the controller follows configuration, not fixed copy.
    panel.setAttribute('data-guided-search-loading-messages-value', JSON.stringify(messages))
    application = Application.start()
    application.register('guided-search-loading', GuidedSearchLoadingController)
    await new Promise(resolve => setTimeout(resolve, 0))
    form = document.querySelector('form')
    status = panel.querySelector('[role="status"]')
    controller = application.getControllerForElementAndIdentifier(panel, 'guided-search-loading')
    jest.useFakeTimers()
    jest.spyOn(Math, 'random').mockReturnValue(0.5)
  })

  afterEach(() => {
    controller.disconnect()
    application.stop()
    document.body.innerHTML = ''
    jest.useRealTimers()
    jest.restoreAllMocks()
  })

  function state(status, followUp = false) {
    form.dispatchEvent(new CustomEvent('queued-search:state', { bubbles: true, detail: { status, followUp } }))
  }

  it('keeps one isolated live region and follows lifecycle signals without illustrative mode', async () => {
    state('submitting')
    expect(status.textContent).toBe('Sending your search.')
    expect(panel.dataset.waiting).toBe('true')
    state('accepted')
    state('queued')
    expect(status.textContent).toBe('Your search is waiting to start.')
    state('running')
    expect(status.textContent).toBe('The service started your search.')
    const textNode = status.firstChild
    state('running')
    await jest.advanceTimersByTimeAsync(60000)
    expect(status.firstChild).toBe(textNode)
    expect(panel.querySelector('[role="status"]')).toBe(status)
    expect(status.getAttribute('aria-live')).toBe('polite')
    expect(status.getAttribute('aria-atomic')).toBe('true')
    expect(status.querySelector('h1, h2, button')).toBeNull()
    expect(panel.querySelector('.app-guided-search-loading__ring').getAttribute('aria-hidden')).toBe('true')
  })

  it('uses answer-specific lifecycle copy', () => {
    state('submitting', true)
    expect(status.textContent).toBe('Sending your answer.')
    state('queued')
    expect(status.textContent).toBe('The search with your answer is waiting to start.')
    state('running')
    expect(status.textContent).toBe('The service started the search with your answer.')
  })

  it('updates the supporting explanation outside the live region with each configured message', async () => {
    controller.illustrativeValue = true
    const description = panel.querySelector('[data-guided-search-loading-target="description"]')
    state('submitting')
    expect(description.textContent).toBe(messages[0].description)
    expect(status.contains(description)).toBe(false)
    await jest.advanceTimersByTimeAsync(2000)
    expect(description.textContent).toBe(messages[1].description)
    state('retrying')
    expect(description.textContent).toBe('')
  })

  it.each([[0, 1000], [0.5, 2000], [0.99, 2980]])('uses random value %s within the configured range', async (random, delay) => {
    Math.random.mockReturnValue(random)
    controller.illustrativeValue = true
    state('submitting')
    expect(status.textContent).toBe(messages[0].text)
    await jest.advanceTimersByTimeAsync(delay - 1)
    state('running')
    expect(status.textContent).toBe(messages[0].text)
    await jest.advanceTimersByTimeAsync(1)
    expect(status.textContent).toBe(messages[1].text)
  })

  it('uses each message range and holds the last message without looping or completing the search', async () => {
    controller.illustrativeValue = true
    state('submitting')
    await jest.advanceTimersByTimeAsync(2000)
    expect(status.textContent).toBe(messages[1].text)
    await jest.advanceTimersByTimeAsync(2999)
    expect(status.textContent).toBe(messages[1].text)
    await jest.advanceTimersByTimeAsync(1)
    expect(status.textContent).toBe(messages[2].text)
    await jest.advanceTimersByTimeAsync(60000)
    state('running')
    expect(status.textContent).toBe(messages[2].text)
    expect(controller.active).toBe(true)
    expect(jest.getTimerCount()).toBe(0)
  })

  it('navigates immediately during the first message without waiting for its delay', async () => {
    controller.illustrativeValue = true
    state('submitting')
    await jest.advanceTimersByTimeAsync(250)
    state('stopped')
    state('navigating')
    expect(status.textContent).toBe('Loading the next page.')
    expect(panel.dataset.waiting).toBe('false')
    expect(jest.getTimerCount()).toBe(0)
    await jest.advanceTimersByTimeAsync(10000)
    expect(status.textContent).toBe('Loading the next page.')
  })

  it('prioritises queue and transport warnings over illustrations', async () => {
    controller.illustrativeValue = true
    state('submitting')
    state('queued')
    await jest.advanceTimersByTimeAsync(10000)
    expect(status.textContent).toBe('Your search is waiting to start.')
    state('running')
    await jest.advanceTimersByTimeAsync(2000)
    state('retrying')
    await jest.advanceTimersByTimeAsync(10000)
    expect(status.textContent).toContain('could not check')
    state('running')
    expect(status.textContent).toBe(messages[1].text)
    await jest.advanceTimersByTimeAsync(3000)
    expect(status.textContent).toBe(messages[2].text)
  })

  it.each(['stopped', 'pagehide', 'bfcache', 'disconnect'])('clears illustration timers and motion on %s', async trigger => {
    controller.illustrativeValue = true
    state('submitting')
    if (trigger === 'stopped') state('stopped')
    if (trigger === 'pagehide') window.dispatchEvent(new Event('pagehide'))
    if (trigger === 'bfcache') window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: true }))
    if (trigger === 'disconnect') controller.disconnect()
    await jest.advanceTimersByTimeAsync(10000)
    expect(status.textContent).toBe(messages[0].text)
    expect(panel.dataset.waiting).toBe('false')
    expect(jest.getTimerCount()).toBe(0)
  })

  it('restarts from the first configured message on a new submission', async () => {
    controller.illustrativeValue = true
    state('submitting')
    await jest.advanceTimersByTimeAsync(2000)
    state('stopped')
    state('submitting', true)
    expect(status.textContent).toBe(messages[0].text)
    await jest.advanceTimersByTimeAsync(2000)
    expect(status.textContent).toBe(messages[1].text)
  })

  it('falls back to lifecycle copy if no valid ranges are configured', () => {
    controller.illustrativeValue = true
    controller.messagesValue = [{ text: 'Invalid delay', min_seconds: 0, max_seconds: -1 }]
    state('submitting')
    state('running')
    expect(status.textContent).toBe('The service started your search.')
    expect(jest.getTimerCount()).toBe(0)
  })
})
