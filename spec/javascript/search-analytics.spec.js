import Cookies from 'js-cookie'
import { publishSearchContext, trackSearchJourney } from '../../app/javascript/src/search-analytics'

describe('search analytics', () => {
  const context = {
    event: 'ott_search_context',
    search_experience: 'guided_beta',
    search_mode: 'guided',
    search_state: 'results',
    feature_flag_name: 'interactive_search',
    feature_flag_enabled: true,
    feature_flag_source: 'flagsmith',
    feature_flag_fallback_reason: null,
    request_id: 'request-123',
    experiment: 'trstd-trdr',
    question_count: 2,
    option_count: 0,
    result_count: 3,
    client_elapsed_ms: 500,
    client_navigation_ms: null,
    used_dont_know: false,
    result_rank: null,
    confidence: null,
    goods_nomenclature_item_id: null,
    outcome: null,
    destination: null,
  }

  beforeEach(() => {
    document.head.innerHTML = `<script type="application/json" id="search-analytics-context">${JSON.stringify(context)}</script>`
    document.body.innerHTML = ''
    Cookies.set('cookies_policy', JSON.stringify({ usage: true }))
    window.dataLayer = []
  })

  afterEach(() => {
    Cookies.remove('cookies_policy')
    delete window.dataLayer
  })

  it('publishes a self-contained results event', () => {
    trackSearchJourney('page_visible', { client_navigation_ms: 1234 })

    expect(window.dataLayer).toEqual([{
      ...context,
      event: 'ott_search_journey',
      outcome: 'page_visible',
      destination: 'results',
      client_navigation_ms: 1234,
    }])
  })

  it.each([false, 'false', null, 1, {}, []])('respects rejected or invalid consent: %j', usage => {
    Cookies.set('cookies_policy', JSON.stringify({ usage }))

    trackSearchJourney('page_visible')
    publishSearchContext(document.createElement('form'))

    expect(window.dataLayer).toEqual([])
  })

  it('does nothing without server consent context', () => {
    document.head.innerHTML = ''
    trackSearchJourney('page_visible')
    expect(window.dataLayer).toEqual([])
  })

  it('does not break a journey when analytics is blocked', () => {
    window.dataLayer.push = () => { throw new Error('blocked') }
    expect(() => trackSearchJourney('page_visible')).not.toThrow()
  })

  it('does not send arbitrary interaction properties', () => {
    trackSearchJourney('dont_know', {
      used_dont_know: true,
      client_elapsed_ms: 123,
      question: 'private question',
      answer: 'private answer',
      expanded_query: 'private expanded query',
    })

    expect(window.dataLayer[0]).toMatchObject({ outcome: 'dont_know', used_dont_know: true, client_elapsed_ms: 123 })
    expect(JSON.stringify(window.dataLayer)).not.toContain('private')
  })

  it('enriches keyword submission within beta and clears prior result context', () => {
    document.body.innerHTML = '<form id="new_search"><input name="q" value="0101210000"><input name="interactive_search" value="false"></form>'

    publishSearchContext(document.querySelector('form'))

    expect(window.dataLayer).toEqual([expect.objectContaining({
      event: 'ott_search_context',
      search_experience: 'guided_beta',
      search_mode: 'keyword',
      request_id: null,
      search_state: 'submitted',
      question_count: null,
      result_count: null,
      client_elapsed_ms: null,
    })])
    expect(JSON.stringify(window.dataLayer)).not.toContain('0101210000')
    expect(window.dataLayer.some(event => event.event === 'ott_search_submitted')).toBe(false)
  })

  it('does not infer beta membership from a submitted field', () => {
    document.getElementById('search-analytics-context').textContent = JSON.stringify({ ...context, search_experience: 'classic' })
    document.body.innerHTML = '<form id="new_search"><input name="q"><input name="interactive_search" value="true"></form>'

    publishSearchContext(document.querySelector('form'))

    expect(window.dataLayer[0]).toMatchObject({ search_experience: 'classic', search_mode: 'keyword' })
  })
})
