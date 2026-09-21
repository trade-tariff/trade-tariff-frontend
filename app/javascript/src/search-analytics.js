import CookieManager from 'cookie-manager'

const METRICS = [
  'question_count', 'option_count', 'result_count', 'used_dont_know',
  'client_elapsed_ms', 'client_navigation_ms', 'result_rank', 'confidence',
  'goods_nomenclature_item_id',
]

const PAGE_VISIBLE_AT_KEY = 'guidedSearchPageVisibleAt'

export function markGuidedSearchPageVisible() {
  try {
    window.sessionStorage.setItem(PAGE_VISIBLE_AT_KEY, String(Date.now()))
  } catch (_) {
    // Analytics must never interrupt search.
  }
}

export function guidedSearchPageElapsedMs() {
  try {
    const startedAt = Number(window.sessionStorage.getItem(PAGE_VISIBLE_AT_KEY))
    if (!Number.isFinite(startedAt) || startedAt <= 0) return null
    return Math.max(0, Math.round(Date.now() - startedAt))
  } catch (_) {
    return null
  }
}

export function searchAnalyticsContext() {
  try {
    if (new CookieManager().usage() !== true) return null
    const element = document.getElementById('search-analytics-context')
    return element ? JSON.parse(element.textContent) : null
  } catch (_) {
    return null
  }
}

function push(properties) {
  try {
    window.dataLayer?.push(properties)
  } catch (_) {
    // Analytics must never interrupt search or the server-side journey events.
  }
}

export function publishSearchContext(form) {
  const context = searchAnalyticsContext()
  if (!context || form.id !== 'new_search' || !form.querySelector('[name="q"]')) return

  const guided = context.search_experience === 'guided_beta' &&
    form.querySelector('[name="interactive_search"]')?.value === 'true'

  // Update GTM's variables before its existing search-submitted trigger runs.
  // Clear the previous results so a refinement cannot look survey-eligible.
  push({
    ...context,
    ...Object.fromEntries(METRICS.map(key => [key, null])),
    event: 'ott_search_context',
    search_mode: guided ? 'guided' : 'keyword',
    search_state: 'submitted',
    request_id: null,
    used_dont_know: false,
    outcome: null,
    destination: null,
  })
}

export function trackSearchJourney(outcome, metrics = {}) {
  const context = searchAnalyticsContext()
  if (!context) return

  push({
    ...context,
    ...Object.fromEntries(Object.entries(metrics).filter(([key]) => METRICS.includes(key))),
    event: 'ott_search_journey',
    outcome,
    destination: context.search_state,
  })
}
