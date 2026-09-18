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
    global.fetch = jest.fn(() => Promise.resolve({ ok: true }))
    adapter = new AmplitudeSurveys(loadSdk)
  })

  afterEach(() => {
    adapter.stop()
    Cookies.remove('cookies_policy')
    delete window.amplitudeGTM
    delete window.amplitude
    delete window.engagement
    window.localStorage.removeItem('amplitude_survey_device_id')
    delete global.fetch
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

  it('preserves the queued results snapshot when Analytics identity is missing', async () => {
    client.getDeviceId.mockReturnValue(undefined)
    const properties = { ...results }
    adapter.results(properties)
    properties.request_id = 'changed-after-the-event'
    await adapter.ready

    expect(sdk.forwardEvent).toHaveBeenCalledWith({
      event_type: 'Search Results Viewed',
      event_properties: expect.objectContaining({ request_id: 'backend-request-123', search_state: 'results' }),
    })
    expect(sdk.boot.mock.calls[0][0].user()).toEqual({
      device_id: expect.any(String), user_id: undefined,
    })
    expect(client.track).not.toHaveBeenCalled()
  })

  it('boots the survey SDK when GTM does not expose an Analytics client', async () => {
    delete window.amplitudeGTM
    adapter.results(results)
    await adapter.ready

    expect(init).toHaveBeenCalledWith(config.apiKey, { serverZone: 'EU' })
    expect(sdk.forwardEvent).toHaveBeenCalledWith({
      event_type: 'Search Results Viewed',
      event_properties: expect.objectContaining({ request_id: 'backend-request-123' }),
    })
    expect(sdk.boot.mock.calls[0][0].user()).toEqual({
      device_id: expect.any(String), user_id: undefined,
    })
  })

  it('sends Search Results Viewed to Amplitude Analytics as well as the survey SDK', async () => {
    delete window.amplitudeGTM
    window.localStorage.setItem('amplitude_survey_device_id', 'stored-device')
    adapter.results(results)
    await adapter.ready

    expect(sdk.forwardEvent).toHaveBeenCalledTimes(1)
    expect(global.fetch).toHaveBeenCalledWith('https://api.eu.amplitude.com/2/httpapi', expect.objectContaining({
      method: 'POST',
      keepalive: true,
    }))
    const body = JSON.parse(global.fetch.mock.calls[0][1].body)
    expect(body.events).toEqual([{
      device_id: 'stored-device',
      event_type: 'Search Results Viewed',
      event_properties: expect.objectContaining({ request_id: 'backend-request-123', search_state: 'results' }),
    }])
  })

  it('posts Analytics events to the US HTTP endpoint', async () => {
    configure({ serverZone: 'US' })
    delete window.amplitudeGTM
    adapter.results(results)
    await adapter.ready
    expect(global.fetch.mock.calls[0][0]).toBe('https://api2.amplitude.com/2/httpapi')
  })

  it('ingests survey responses over HTTP when GTM has no Analytics client', async () => {
    delete window.amplitudeGTM
    window.localStorage.setItem('amplitude_survey_device_id', 'stored-device')
    adapter.start()
    await adapter.ready
    global.fetch.mockClear()
    sdk.boot.mock.calls[0][0].integrations[0].track({
      event_type: '[Amplitude] Survey Submitted', event_properties: { answer: 'Good' },
    })
    expect(JSON.parse(global.fetch.mock.calls[0][1].body).events).toEqual([{
      device_id: 'stored-device',
      event_type: '[Amplitude] Survey Submitted',
      event_properties: { answer: 'Good' },
    }])
  })

  it('isolates Analytics HTTP failures', async () => {
    global.fetch.mockImplementation(() => { throw new Error('blocked') })
    delete window.amplitudeGTM
    adapter.results(results)
    await expect(adapter.ready).resolves.toBeUndefined()
    expect(sdk.forwardEvent).toHaveBeenCalledTimes(1)
  })

  it('uses window.amplitude when amplitudeGTM is absent', async () => {
    delete window.amplitudeGTM
    window.amplitude = client
    adapter.start()
    await adapter.ready
    expect(sdk.boot.mock.calls[0][0].user()).toEqual({ device_id: 'existing-device', user_id: undefined })
  })

  it('reuses a stored anonymous device id when Analytics is absent', async () => {
    delete window.amplitudeGTM
    window.localStorage.setItem('amplitude_survey_device_id', 'stored-device')
    adapter.start()
    await adapter.ready
    expect(sdk.boot.mock.calls[0][0].user()).toEqual({ device_id: 'stored-device', user_id: undefined })
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
    const removeListener = jest.spyOn(window, 'removeEventListener')
    adapter.results(results)
    const externalSdk = { boot: jest.fn(), shutdown: jest.fn() }
    window.engagement = externalSdk
    loading.resolve({ init })
    await adapter.ready
    expect(init).not.toHaveBeenCalled()
    expect(adapter.pending).toBeNull()
    expect(adapter.stopped).toBe(true)
    expect(removeListener).toHaveBeenCalledWith('cookies:changed', adapter.onConsentChange)
    expect(removeListener).toHaveBeenCalledWith('pagehide', adapter.onPageHide)
    expect(externalSdk.shutdown).not.toHaveBeenCalled()
    removeListener.mockRestore()
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
    const response = {
      event_type: '[Amplitude] Survey Submitted', event_properties: { answer: 'Good' },
      groups: { organisation: 'trader' }, time: 1789495691346, insert_id: 'survey-response-123',
    }
    sdk.boot.mock.calls[0][0].integrations[0].track(response)
    expect(client.track).toHaveBeenCalledWith(response)
    expect(client.track.mock.calls[0][0]).toBe(response)
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

  it.each(['consent', 'getDeviceId', 'getUserId'])('discards results if %s changes during import', async change => {
    const loading = deferred()
    loadSdk.mockReturnValue(loading.promise)
    adapter.results(results)
    if (change === 'consent') new CookieManager().setCookiesPolicy({ usage: false })
    else client[change].mockReturnValue('another-identity')
    loading.resolve({ init })
    await adapter.ready
    expect(init).not.toHaveBeenCalled()
    expect(adapter.pending).toBeNull()
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
