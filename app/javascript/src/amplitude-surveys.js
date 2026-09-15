import CookieManager from 'cookie-manager'

const WAIT_MS = 100
const TIMEOUT_MS = 10000

async function withTimeout(promise) {
  let timer
  try {
    return await Promise.race([
      promise,
      new Promise((_, reject) => {
        timer = setTimeout(() => reject(new Error('Survey SDK readiness timeout')), TIMEOUT_MS)
      }),
    ])
  } finally {
    clearTimeout(timer)
  }
}

function consented() {
  return new CookieManager().usage() === true
}

// GTM remains the only Analytics owner. Never create a second device identity.
function analyticsClient(instanceName) {
  const root = window.amplitudeGTM
  const client = instanceName ? root?._iq?.[instanceName] : root
  if (typeof client?.getDeviceId !== 'function' ||
      typeof client?.getUserId !== 'function' || typeof client?.track !== 'function') return null
  return client.getDeviceId() ? client : null
}

export class AmplitudeSurveys {
  constructor(loadSdk = () => import('@amplitude/engagement-browser')) {
    this.loadSdk = loadSdk
    this.pending = null
    this.started = false
    this.stopped = false
    this.sdk = null
    this.forwarded = false
    this.onConsentChange = () => { if (!consented()) this.stop() }
    this.onPageHide = () => this.stop()
  }

  start() {
    if (this.started || this.stopped || !consented()) return
    const element = document.getElementById('amplitude-surveys-config')
    if (!element) return

    this.started = true
    window.addEventListener('cookies:changed', this.onConsentChange)
    window.addEventListener('pagehide', this.onPageHide)
    // Survey failures must not interrupt search or GTM's analytics delivery.
    this.ready = this.boot(JSON.parse(element.textContent)).catch(() => this.stop())
  }

  async boot(config) {
    if (!/^[a-f0-9]{32}$/i.test(config.apiKey) || !['EU', 'US'].includes(config.serverZone)) return
    const deadline = Date.now() + TIMEOUT_MS
    let client
    while (!this.stopped && consented() && Date.now() < deadline) {
      client = analyticsClient(config.instanceName)
      if (client) break
      await new Promise(resolve => setTimeout(resolve, WAIT_MS))
    }
    if (!client || this.stopped || !consented()) return this.stop()
    // Fail closed if GTM or another integration already owns Engagement.
    if (window.engagement) return this.stop()
    const { init } = await withTimeout(this.loadSdk())
    if (this.stopped || !consented() || window.engagement) return

    init(config.apiKey, { serverZone: config.serverZone })
    this.sdk = window.engagement
    const deviceId = client.getDeviceId()
    const userId = client.getUserId()
    this.sameIdentity = () => client.getDeviceId() === deviceId && client.getUserId() === userId
    this.monitor = setInterval(() => {
      if (!this.active()) this.stop()
    }, WAIT_MS)
    await withTimeout(Promise.resolve(this.sdk.boot({
      // The loader queues boot while fetching its runtime. Recheck when the
      // runtime actually consumes the identity, not only when we enqueue it.
      user: () => this.active() ? { device_id: deviceId, user_id: userId } : {},
      integrations: [{
        track: event => {
          if (!this.active()) {
            this.stop()
            return
          }
          try {
            const result = client.track(event.event_type, event.event_properties)
            result?.promise?.catch(() => {})
          } catch (_) { /* Analytics failure must not break the survey. */ }
        },
      }],
    })).then(() => {
      // Also shut down if boot resolves after our readiness timeout.
      if (this.stopped || !consented()) this.stop()
    }))
    if (!this.active()) {
      this.stop()
      return
    }
    this.booted = true
    this.flush()
  }

  active() {
    try {
      return !this.stopped && consented() && this.sameIdentity()
    } catch (_) {
      return false
    }
  }

  results(properties) {
    if (!consented() || this.stopped || this.forwarded ||
        properties.outcome !== 'page_visible' || properties.search_state !== 'results') return
    // Snapshot this rendered page, not mutable GTM variables read after SDK boot.
    const { event, ...context } = properties
    this.pending = { event_type: 'Search Results Viewed', event_properties: context }
    this.start()
    this.flush()
  }

  flush() {
    if (!this.booted || !this.pending || this.stopped) return
    if (!this.active()) {
      this.stop()
      return
    }
    const event = this.pending
    this.pending = null
    this.forwarded = true
    this.sdk.forwardEvent(event)
  }

  clearPending() {
    this.pending = null
  }

  stop() {
    this.stopped = true
    this.pending = null
    this.booted = false
    clearInterval(this.monitor)
    window.removeEventListener('cookies:changed', this.onConsentChange)
    window.removeEventListener('pagehide', this.onPageHide)
    try { this.sdk?.shutdown() } catch (_) { /* SDK failure must not affect consent. */ }
  }
}

const surveys = new AmplitudeSurveys()

export function startAmplitudeSurveys() {
  try { surveys.start() } catch (_) { /* Optional integration. */ }
}

export function forwardSurveyResults(properties) {
  try { surveys.results(properties) } catch (_) { /* Optional integration. */ }
}

export function clearPendingSurveyResults() {
  surveys.clearPending()
}
