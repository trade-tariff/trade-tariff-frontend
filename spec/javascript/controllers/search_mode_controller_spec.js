import { Application } from '@hotwired/stimulus'
import SearchModeController from '../../../app/javascript/controllers/search_mode_controller'

const settle = () => new Promise(resolve => setTimeout(resolve, 0))

describe('SearchModeController', () => {
  let application
  const form = () => document.querySelector('form')
  const tab = mode => document.querySelector(`[data-mode="${mode}"]`)
  const panel = mode => document.getElementById(mode)

  async function setup(initialMode = 'keyword', errors = false) {
    document.body.innerHTML = `
      <form data-controller="search-mode" data-search-mode-initial-mode-value="${initialMode}">
        ${errors ? '<div class="govuk-error-summary">Check your search</div>' : ''}
        <ul hidden data-search-mode-target="tabs" role="tablist">
          <li class="govuk-tabs__list-item"><a href="#keyword" id="keyword-tab" role="tab" aria-controls="keyword" data-search-mode-target="tab" data-mode="keyword" data-action="click->search-mode#select keydown->search-mode#navigate">Keyword</a></li>
          <li class="govuk-tabs__list-item"><a href="#guided" id="guided-tab" role="tab" aria-controls="guided" data-search-mode-target="tab" data-mode="guided" data-action="click->search-mode#select keydown->search-mode#navigate">AI-assisted</a></li>
        </ul>
        <div id="keyword" data-search-mode-target="keywordSection"><input name="q" value="bicycle"></div>
        <div id="guided" hidden data-search-mode-target="guidedSection"><textarea name="q" disabled>cotton shirt</textarea></div>
        <input name="interactive_search" value="false" data-search-mode-target="hiddenField">
        <input name="day" value="12">
      </form>`
    application = Application.start()
    application.register('search-mode', SearchModeController)
    await settle()
  }

  afterEach(() => {
    application?.stop()
    document.body.innerHTML = ''
    document.cookie = 'interactive_search=; max-age=0'
    window.history.replaceState({}, '', '/')
    delete performance.getEntriesByType
    jest.restoreAllMocks()
  })

  it('enhances the keyword fallback with an accessible selected tab', async () => {
    document.cookie = 'interactive_search=true'
    await setup()
    expect(document.querySelector('[role="tablist"]').hidden).toBe(false)
    expect(tab('keyword').getAttribute('aria-selected')).toBe('true')
    expect(tab('keyword').tabIndex).toBe(0)
    expect(tab('guided').tabIndex).toBe(-1)
    expect(panel('keyword').hidden).toBe(false)
    expect(panel('guided').hidden).toBe(true)
    expect(new FormData(form()).getAll('q')).toEqual(['bicycle'])
  })
  it('preserves each query and shared date while submitting only the active query', async () => {
    await setup()
    const click = new MouseEvent('click', { bubbles: true, cancelable: true })
    tab('guided').dispatchEvent(click)
    expect(click.defaultPrevented).toBe(true)
    expect(tab('guided').parentElement.classList.contains('govuk-tabs__list-item--selected')).toBe(true)
    expect(tab('keyword').parentElement.classList.contains('govuk-tabs__list-item--selected')).toBe(false)
    expect(panel('guided').hidden).toBe(false)
    expect(new FormData(form()).getAll('q')).toEqual(['cotton shirt'])
    expect(new FormData(form()).get('interactive_search')).toBe('true')
    expect(new FormData(form()).get('day')).toBe('12')
    tab('keyword').click()
    expect(new FormData(form()).getAll('q')).toEqual(['bicycle'])
    expect(panel('guided').querySelector('textarea').value).toBe('cotton shirt')
  })

  it.each([
    ['ArrowRight', 'keyword', 'guided'], ['ArrowLeft', 'keyword', 'guided'],
    ['ArrowRight', 'guided', 'keyword'], ['Home', 'guided', 'keyword'],
    ['End', 'keyword', 'guided'], [' ', 'keyword', 'keyword']
  ])('moves focus and selection with %s from %s', async (key, start, expected) => {
    await setup()
    tab(start).click()
    tab(start).focus()
    tab(start).dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true }))
    expect(document.activeElement).toBe(tab(expected))
    expect(tab(expected).getAttribute('aria-selected')).toBe('true')
    expect(panel(expected).hidden).toBe(false)
  })

  it('opens a usable AI form from the service-update fragment', async () => {
    window.history.replaceState({}, '', '/find_commodity#ai-search-panel')
    await setup()
    expect(tab('guided').getAttribute('aria-selected')).toBe('true')
    expect(panel('guided').hidden).toBe(false)
    expect(new FormData(form()).get('interactive_search')).toBe('true')
    expect(new FormData(form()).getAll('q')).toEqual(['cotton shirt'])
  })

  it.each(['#unknown', '#keyword-search-panel', '#AI-search-panel'])('ignores the unrelated fragment %s', async hash => {
    window.history.replaceState({}, '', `/find_commodity${hash}`)
    await setup()
    expect(panel('keyword').hidden).toBe(false)
  })

  it.each(['keyword', 'guided'])('preserves %s validation errors over fragment selection', async mode => {
    window.history.replaceState({}, '', '/find_commodity#ai-search-panel')
    await setup(mode, true)
    expect(panel(mode).hidden).toBe(false)
  })

  it('keeps keyword on reload even with the return fragment', async () => {
    window.history.replaceState({}, '', '/find_commodity#ai-search-panel')
    Object.defineProperty(performance, 'getEntriesByType', {
      configurable: true, value: jest.fn(() => [{ type: 'reload' }])
    })
    await setup()
    expect(panel('keyword').hidden).toBe(false)
  })

  it('opens the submitted AI mode after a server validation error', async () => {
    await setup('guided')
    expect(panel('guided').hidden).toBe(false)
  })

  it('starts on keyword when a server validation response is refreshed', async () => {
    Object.defineProperty(performance, 'getEntriesByType', {
      configurable: true, value: jest.fn(() => [{ type: 'reload' }])
    })
    await setup('guided')
    expect(panel('keyword').hidden).toBe(false)
    delete performance.getEntriesByType
  })

  it('excludes autocomplete fields added while the keyword panel is inactive', async () => {
    await setup()
    tab('guided').click()
    panel('keyword').insertAdjacentHTML('beforeend', '<input type="hidden" name="q" value="late autocomplete query">')
    await settle()
    expect(new FormData(form()).getAll('q')).toEqual(['cotton shirt'])
  })

  it('hides inactive search errors while retaining shared date errors', async () => {
    await setup('guided')
    form().insertAdjacentHTML('afterbegin', `<div class="govuk-error-summary"><ul>
      <li data-search-mode-error="guided">Enter a description</li>
      <li id="date-error">Enter a valid date</li>
    </ul></div>`)
    await settle()
    tab('keyword').click()
    expect(document.querySelector('[data-search-mode-error]').hidden).toBe(true)
    expect(document.querySelector('.govuk-error-summary').hidden).toBe(false)
    document.getElementById('date-error').remove()
    await settle()
    expect(document.querySelector('.govuk-error-summary').hidden).toBe(true)
    tab('guided').click()
    expect(document.querySelector('.govuk-error-summary').hidden).toBe(false)
  })

  it('scopes dynamically inserted client validation errors to the AI panel', async () => {
    await setup('guided')
    form().insertAdjacentHTML('afterbegin', '<div class="govuk-error-summary" data-search-mode-error="guided"><ul><li>Enter a description</li></ul></div>')
    tab('keyword').click()
    await settle()
    expect(document.querySelector('.govuk-error-summary').hidden).toBe(true)
    tab('guided').click()
    expect(document.querySelector('.govuk-error-summary').hidden).toBe(false)
  })
  it('labels enhanced search panels with their controlling tabs', async () => {
    await setup()
    for (const mode of ['keyword', 'guided']) {
      expect(panel(mode).getAttribute('role')).toBe('tabpanel')
      expect(panel(mode).getAttribute('aria-labelledby')).toBe(tab(mode).id)
      expect(tab(mode).getAttribute('aria-controls')).toBe(panel(mode).id)
    }
  })

  it('scopes server summary links to their search panel while retaining date errors', async () => {
    await setup('guided')
    panel('guided').insertAdjacentHTML('beforeend', '<p id="search-q-field-error">Enter a description</p>')
    form().insertAdjacentHTML('afterbegin', `<div class="govuk-error-summary"><ul>
      <li id="query-summary-error"><a href="#search-q-field-error">Enter a description</a></li>
      <li id="date-summary-error"><a href="#date-field-error">Enter a date</a></li>
      <li id="external-summary-error"><a href="https://example.com/#search-q-field-error">External information</a></li>
    </ul></div><p id="date-field-error">Enter a date</p>`)
    await settle()
    tab('keyword').click()
    expect(document.getElementById('query-summary-error').hidden).toBe(true)
    expect(document.getElementById('date-summary-error').hidden).toBe(false)
    expect(document.getElementById('external-summary-error').hidden).toBe(false)
    expect(document.querySelector('.govuk-error-summary').hidden).toBe(false)
    tab('guided').click()
    expect(document.getElementById('query-summary-error').hidden).toBe(false)
  })

})
