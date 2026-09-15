import Cookies from 'js-cookie'
import CookieManager from '../../app/javascript/src/cookie-manager'
import { AmplitudeSurveys } from '../../app/javascript/src/amplitude-surveys'

const config = { apiKey: 'a'.repeat(32), serverZone: 'EU', instanceName: '' }
const results = {
  event: 'ott_search_journey', outcome: 'page_visible', search_state: 'results',
  request_id: 'backend-request-123', search_experience: 'guided_beta', search_mode: 'guided',
  feature_flag_source: 'flagsmith', feature_flag_enabled: true,
}

function deferred() {
  let resolve
  const promise = new Promise(done => { resolve = done })
  return { promise, resolve }
}

describe('Amplitude survey integration', () => {
  let adapter, sdk, client, init, loadSdk

  function configure(overrides = {}) {
    document.head.innerHTML = `<script id="amplitude-surveys-config" type="application/json">${JSON.stringify({ ...config, ...overrides })}</script>`
  }

  beforeEach(() => {
    jest.useFakeTimers()
    Cookies.set('cookies_policy', JSON.stringify({ usage: true }))
    configure()
    client = {
      getDeviceId: jest.fn(() => 'existing-device'), getUserId: jest.fn(() => undefined),
      track: jest.fn(() => ({ promise: Promise.resolve() })),
    }
    window.amplitudeGTM = client
    sdk = { boot: jest.fn().mockResolvedValue(), shutdown: jest.fn(), forwardEvent: jest.fn() }
    init = jest.fn(() => { window.engagement = sdk })
    loadSdk = jest.fn().mockResolvedValue({ init })
    adapter = new AmplitudeSurveys(loadSdk)
  })

  afterEach(() => {
    adapter.stop()
    Cookies.remove('cookies_policy')
    delete window.amplitudeGTM
    delete window.engagement
    document.head.innerHTML = ''
    jest.clearAllTimers()
    jest.useRealTimers()
  })

  it('boots for Preview on an entry page, using the existing anonymous identity', async () => {
    adapter.start()
    await adapter.ready

    expect(init).toHaveBeenCalledWith(config.apiKey, { serverZone: 'EU' })
    expect(sdk.boot).toHaveBeenCalledWith({
      user: expect.any(Function),
      integrations: [{ track: expect.any(Function) }],
    })
    expect(sdk.boot.mock.calls[0][0].user()).toEqual({ device_id: 'existing-device', user_id: undefined })
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it.each([true, 'true'])('accepts supported consent %j', async usage => {
    Cookies.set('cookies_policy', JSON.stringify({ usage }))
    adapter.start()
    await adapter.ready
    expect(loadSdk).toHaveBeenCalledTimes(1)
  })

  it.each([false, 'false', null, 1, {}, []])('does not load or queue with consent %j', usage => {
    Cookies.set('cookies_policy', JSON.stringify({ usage }))
    adapter.results(results)
    expect(loadSdk).not.toHaveBeenCalled()
    expect(adapter.pending).toBeNull()
  })

  it('does not load without server-rendered configuration', () => {
    document.head.innerHTML = ''
    adapter.start()
    expect(loadSdk).not.toHaveBeenCalled()
  })

  it.each([{ apiKey: '' }, { apiKey: 'not-a-project-key' }, { serverZone: '' }, { serverZone: 'GB' }])('rejects invalid configuration %j', async overrides => {
    configure(overrides)
    adapter.start()
    await adapter.ready
    expect(loadSdk).not.toHaveBeenCalled()
  })

  it('waits for GTM identity and preserves the queued results snapshot', async () => {
    client.getDeviceId.mockReturnValue(undefined)
    const properties = { ...results }
    adapter.results(properties)
    properties.request_id = 'changed-after-the-event'
    expect(loadSdk).not.toHaveBeenCalled()
    client.getDeviceId.mockReturnValue('existing-device')
    await jest.advanceTimersByTimeAsync(100)
    await adapter.ready

    expect(sdk.forwardEvent).toHaveBeenCalledWith({
      event_type: 'Search Results Viewed',
      event_properties: expect.objectContaining({ request_id: 'backend-request-123', search_state: 'results' }),
    })
    expect(client.track).not.toHaveBeenCalled()
  })

  it('times out without inventing a device ID if GTM is blocked', async () => {
    delete window.amplitudeGTM
    adapter.results(results)
    await jest.advanceTimersByTimeAsync(10000)
    await adapter.ready
    expect(loadSdk).not.toHaveBeenCalled()
    expect(adapter.pending).toBeNull()
  })

  it('uses the configured named GTM instance and its signed-in identity', async () => {
    configure({ instanceName: 'tariff' })
    client.getUserId.mockReturnValue('existing-user')
    window.amplitudeGTM = { _iq: { tariff: client } }
    adapter.start()
    await adapter.ready
    expect(sdk.boot.mock.calls[0][0].user()).toEqual({ device_id: 'existing-device', user_id: 'existing-user' })
  })

  it('does not initialise a duplicate Engagement SDK', async () => {
    window.engagement = { boot: jest.fn() }
    adapter.results(results)
    await adapter.ready
    expect(loadSdk).not.toHaveBeenCalled()
    expect(window.engagement.boot).not.toHaveBeenCalled()
    expect(adapter.pending).toBeNull()
  })

  it('rechecks ownership after the asynchronous import', async () => {
    const loading = deferred()
    loadSdk.mockReturnValue(loading.promise)
    adapter.start()
    window.engagement = { boot: jest.fn() }
    loading.resolve({ init })
    await adapter.ready
    expect(init).not.toHaveBeenCalled()
  })

  it('waits for boot before forwarding, and deduplicates page reconnects', async () => {
    const booting = deferred()
    sdk.boot.mockReturnValue(booting.promise)
    adapter.results(results)
    adapter.results(results)
    await jest.advanceTimersByTimeAsync(0)
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
    booting.resolve()
    await adapter.ready
    adapter.results(results)
    expect(loadSdk).toHaveBeenCalledTimes(1)
    expect(sdk.forwardEvent).toHaveBeenCalledTimes(1)
  })

  it.each(['entry', 'question', 'no_results', 'unknown_results', 'blocking_guidance', 'input_error', 'backend_error', null])('does not trigger for state %s', async search_state => {
    adapter.results({ ...results, search_state })
    expect(adapter.pending).toBeNull()
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it.each(['dont_know', 'result_selected'])('does not trigger for interaction %s', outcome => {
    adapter.results({ ...results, outcome })
    expect(adapter.pending).toBeNull()
  })

  it.each([
    { search_experience: 'classic', search_mode: 'keyword' },
    { search_experience: 'guided_beta', search_mode: 'keyword' },
  ])('retains actual attribution for %j', async context => {
    adapter.results({ ...results, ...context })
    await adapter.ready
    expect(sdk.forwardEvent.mock.calls[0][0].event_properties).toMatchObject(context)
  })

  it('records SDK-generated responses through existing Analytics without inventing search attribution', async () => {
    adapter.start()
    await adapter.ready
    const response = { event_type: '[Amplitude] Survey Submitted', event_properties: { answer: 'Good' } }
    sdk.boot.mock.calls[0][0].integrations[0].track(response)
    expect(client.track).toHaveBeenCalledWith(response.event_type, response.event_properties)
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it('drops pending results when another search is submitted', async () => {
    const booting = deferred()
    sdk.boot.mockReturnValue(booting.promise)
    adapter.results(results)
    adapter.clearPending()
    booting.resolve()
    await adapter.ready
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it('stops immediately on consent withdrawal and drops late boot results and responses', async () => {
    const booting = deferred()
    sdk.boot.mockReturnValue(booting.promise)
    adapter.results(results)
    await jest.advanceTimersByTimeAsync(0)
    new CookieManager().setCookiesPolicy({ usage: false })
    expect(sdk.shutdown).toHaveBeenCalled()
    booting.resolve()
    await adapter.ready
    sdk.boot.mock.calls[0][0].integrations[0].track({ event_type: 'response' })
    expect(client.track).not.toHaveBeenCalled()
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
    expect(adapter.pending).toBeNull()
  })

  it.each(['consent', 'identity'])('does not expose stale identity to a queued runtime boot after %s changes', async change => {
    const booting = deferred()
    sdk.boot.mockReturnValue(booting.promise)
    adapter.results(results)
    await jest.advanceTimersByTimeAsync(0)
    const queuedBoot = sdk.boot.mock.calls[0][0]
    if (change === 'consent') new CookieManager().setCookiesPolicy({ usage: false })
    else client.getDeviceId.mockReturnValue('another-device')
    // Model the vendor loader executing its queued boot before queued shutdown.
    expect(queuedBoot.user()).toEqual({})
    queuedBoot.integrations[0].track({ event_type: 'response' })
    expect(client.track).not.toHaveBeenCalled()
    booting.resolve()
    await adapter.ready
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it('fails closed when the existing Analytics identity getter throws', async () => {
    adapter.start()
    await adapter.ready
    client.getDeviceId.mockImplementation(() => { throw new Error('unavailable') })
    const queuedBoot = sdk.boot.mock.calls[0][0]
    expect(queuedBoot.user()).toEqual({})
    expect(() => queuedBoot.integrations[0].track({ event_type: 'response' })).not.toThrow()
    expect(client.track).not.toHaveBeenCalled()
    expect(sdk.shutdown).toHaveBeenCalled()
  })

  it('does not initialise if consent is withdrawn during import', async () => {
    const loading = deferred()
    loadSdk.mockReturnValue(loading.promise)
    adapter.start()
    new CookieManager().setCookiesPolicy({ usage: false })
    loading.resolve({ init })
    await adapter.ready
    expect(init).not.toHaveBeenCalled()
  })

  it('stops if the analytics identity changes after boot', async () => {
    adapter.start()
    await adapter.ready
    client.getDeviceId.mockReturnValue('different-device')
    await jest.advanceTimersByTimeAsync(100)
    expect(sdk.shutdown).toHaveBeenCalled()
    adapter.results(results)
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it('cancels pending delivery on navigation', async () => {
    const booting = deferred()
    sdk.boot.mockReturnValue(booting.promise)
    adapter.results(results)
    window.dispatchEvent(new Event('pagehide'))
    booting.resolve()
    await adapter.ready
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
  })

  it.each(['import', 'boot'])('bounds a stalled %s and discards the pending event', async stage => {
    const stalled = deferred()
    if (stage === 'import') loadSdk.mockReturnValue(stalled.promise)
    else sdk.boot.mockReturnValue(stalled.promise)
    adapter.results(results)
    await jest.advanceTimersByTimeAsync(10000)
    await adapter.ready
    expect(adapter.pending).toBeNull()
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
    stalled.resolve(stage === 'import' ? { init } : undefined)
    await jest.advanceTimersByTimeAsync(0)
    expect(sdk.forwardEvent).not.toHaveBeenCalled()
    if (stage === 'import') expect(init).not.toHaveBeenCalled()
    else expect(sdk.shutdown).toHaveBeenCalled()
  })

  it('isolates synchronous and asynchronous response tracking failures', async () => {
    adapter.start()
    await adapter.ready
    const track = sdk.boot.mock.calls[0][0].integrations[0].track
    client.track.mockImplementation(() => { throw new Error('blocked') })
    expect(() => track({ event_type: 'response' })).not.toThrow()
    client.track.mockImplementation(() => ({ promise: Promise.reject(new Error('blocked')) }))
    expect(() => track({ event_type: 'response' })).not.toThrow()
    await jest.advanceTimersByTimeAsync(0)
  })

  it.each(['import', 'boot'])('isolates %s failures', async stage => {
    if (stage === 'import') loadSdk.mockRejectedValue(new Error('blocked'))
    else sdk.boot.mockRejectedValue(new Error('blocked'))
    adapter.results(results)
    await expect(adapter.ready).resolves.toBeUndefined()
    expect(adapter.pending).toBeNull()
  })
})
