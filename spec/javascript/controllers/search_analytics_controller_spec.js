import { Application } from '@hotwired/stimulus'
import Cookies from 'js-cookie'
import SearchAnalyticsController from '../../../app/javascript/controllers/search_analytics_controller'
import GuidedSearchPageController from '../../../app/javascript/controllers/guided_search_page_controller'
import GuidedSearchResultController from '../../../app/javascript/controllers/guided_search_result_controller'
import InteractiveQuestionController from '../../../app/javascript/controllers/interactive_question_controller'

describe('search journey analytics integration', () => {
  let application

  async function start(context, content = '') {
    document.head.innerHTML = `<meta name="csrf-token" content="csrf-token-123">
      <script type="application/json" id="search-analytics-context">${JSON.stringify(context)}</script>`
    document.body.innerHTML = `<div data-controller="search-analytics"
      data-action="submit@window->search-analytics#submit:capture">${content}</div>`
    application = Application.start()
    application.register('search-analytics', SearchAnalyticsController)
    application.register('guided-search-page', GuidedSearchPageController)
    application.register('guided-search-result', GuidedSearchResultController)
    application.register('interactive-question', InteractiveQuestionController)
    await new Promise(resolve => setTimeout(resolve, 0))
  }

  const guidedContext = {
    search_experience: 'guided_beta', search_mode: 'guided',
    search_state: 'results', request_id: 'request-123',
    feature_flag_name: 'interactive_search', feature_flag_enabled: true,
    feature_flag_source: 'flagsmith', result_count: 3,
  }

  const guidedPage = `<div data-controller="guided-search-page"
    data-guided-search-page-event-url-value="/search/guided-search-event"
    data-guided-search-page-request-id-value="request-123"
    data-guided-search-page-outcome-value="results"></div>`

  beforeEach(() => {
    Cookies.set('cookies_policy', JSON.stringify({ usage: true }))
    window.dataLayer = []
    window.fetch = jest.fn().mockResolvedValue({ ok: true })
  })

  afterEach(() => {
    application?.stop()
    Cookies.remove('cookies_policy')
    window.sessionStorage.clear()
    delete window.dataLayer
    delete window.fetch
    jest.restoreAllMocks()
  })

  it('emits one guided results event even without navigation timing', async () => {
    await start(guidedContext, guidedPage)

    expect(window.dataLayer).toEqual([expect.objectContaining({
      ...guidedContext, event: 'ott_search_journey', outcome: 'page_visible', destination: 'results',
    })])
  })

  it('reports timing to both analytics and existing server monitoring', async () => {
    window.sessionStorage.setItem('guidedSearchSubmittedAt', '1000')
    jest.spyOn(Date, 'now').mockReturnValue(2234)

    await start(guidedContext, guidedPage)

    expect(window.dataLayer).toEqual([expect.objectContaining({ client_navigation_ms: 1234 })])
    expect(JSON.parse(window.fetch.mock.calls[0][1].body)).toMatchObject({
      event_type: 'page_visible', request_id: 'request-123', client_navigation_ms: 1234,
    })
  })

  it('preserves server monitoring when consent is absent', async () => {
    Cookies.remove('cookies_policy')
    window.sessionStorage.setItem('guidedSearchSubmittedAt', '1000')
    await start(guidedContext, guidedPage)

    expect(window.fetch).toHaveBeenCalled()
    expect(window.dataLayer).toEqual([])
  })

  it('exposes classic results at the same shared URL', async () => {
    await start({ ...guidedContext, search_experience: 'classic', search_mode: 'keyword' })

    expect(window.dataLayer).toEqual([expect.objectContaining({
      event: 'ott_search_journey', search_experience: 'classic', destination: 'results',
    })])
  })

  it('updates mode before GTM observes a submission', async () => {
    let submittedContext
    const observeSubmission = () => { submittedContext = window.dataLayer.at(-1) }
    // GTM may register a document capture listener before Stimulus starts.
    document.addEventListener('submit', observeSubmission, true)
    await start({ ...guidedContext, search_state: 'entry' },
      '<form id="new_search"><input name="q"><input name="interactive_search" value="false"></form>')
    window.dataLayer.length = 0
    document.querySelector('form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
    document.removeEventListener('submit', observeSubmission, true)

    expect(submittedContext).toMatchObject({ search_mode: 'keyword', search_experience: 'guided_beta' })
  })

  it.each(['order_number', 'cas'])('ignores the unrelated search form containing %s', async field => {
    await start({ ...guidedContext, search_state: null },
      `<form id="new_search"><input name="${field}"></form>`)

    document.querySelector('form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))

    expect(window.dataLayer).toEqual([])
  })

  it('waits for a commodity search on a non-search page', async () => {
    await start({ ...guidedContext, search_state: null, search_mode: 'keyword', request_id: null, result_count: null },
      '<form id="new_search"><input name="q" value="coffee"></form>')

    expect(window.dataLayer).toEqual([])

    document.querySelector('form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))

    expect(window.dataLayer).toEqual([expect.objectContaining({
      event: 'ott_search_context', search_state: 'submitted', search_mode: 'keyword',
      search_experience: 'guided_beta', feature_flag_source: 'flagsmith',
    })])
    expect(JSON.stringify(window.dataLayer)).not.toContain('coffee')
  })

  it('reports selected rank and confidence while retaining the server event', async () => {
    await start(guidedContext, `<a href="#" data-controller="guided-search-result"
      data-action="click->guided-search-result#select"
      data-guided-search-result-event-url-value="/search/guided-search-event"
      data-guided-search-result-request-id-value="request-123"
      data-guided-search-result-goods-nomenclature-item-id-value="0101210000"
      data-guided-search-result-rank-value="2"
      data-guided-search-result-confidence-value="Good">View code</a>`)
    document.querySelector('a').click()

    expect(window.dataLayer).toEqual([expect.objectContaining({
      outcome: 'result_selected', result_rank: 2, confidence: 'good',
      goods_nomenclature_item_id: '0101210000', request_id: 'request-123',
    })])
    expect(window.fetch).toHaveBeenCalled()
  })

  it('reports I do not know without sending the answer text', async () => {
    await start({ ...guidedContext, search_state: 'question' }, `<div data-controller="interactive-question"
      data-interactive-question-event-url-value="/search/guided-search-event"
      data-interactive-question-request-id-value="request-123"
      data-interactive-question-question-number-value="2">
      <form data-action="submit->interactive-question#submitWithThinking">
        <input type="radio" name="interactive_search_form[answer]" value="I don't know" checked>
      </form></div>`)
    document.querySelector('form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))

    expect(window.dataLayer).toEqual([expect.objectContaining({
      outcome: 'dont_know', used_dont_know: true, question_count: 2,
      client_elapsed_ms: expect.any(Number),
    })])
    expect(JSON.stringify(window.dataLayer)).not.toContain("I don't know")
    expect(window.fetch).toHaveBeenCalled()
  })
})
