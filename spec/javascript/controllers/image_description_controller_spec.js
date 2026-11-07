import { readFileSync } from 'node:fs'
import { Application } from '@hotwired/stimulus'
import ImageDescriptionController from '../../../app/javascript/controllers/image_description_controller'

const controls = readFileSync(`${__dirname}/../../../app/views/shared/search/_image_description_controls.html.erb`, 'utf8')
const reply = (body, status = 200) => ({ ok: status >= 200 && status < 300, status, json: async () => body })
const accepted = () => reply({ status: 'queued', poll_url: '/search/image-descriptions/123?token=signed-grant' }, 202)
const completed = (description = 'A cotton shirt.') => reply({ status: 'completed', description, uncertainties: ['Check the fibre content.'] })
const image = () => new File(['synthetic image'], 'shirt.png', { type: 'image/png' })

describe('ImageDescriptionController', () => {
  let application, controller, form, textarea

  beforeEach(async () => {
    document.head.innerHTML = '<meta name="csrf-token" content="test-csrf">'
    document.body.innerHTML = `<form data-controller="image-description" data-image-description-url-value="/search/image-descriptions">
      <textarea name="q" data-image-description-target="textarea"
        data-action="dragover->image-description#dragover drop->image-description#drop input->image-description#edited">My original text</textarea>
      ${controls}<button type="submit">Search for a commodity</button></form>`
    application = Application.start()
    application.register('image-description', ImageDescriptionController)
    await new Promise(resolve => setTimeout(resolve, 0))
    form = document.querySelector('form')
    textarea = form.querySelector('textarea')
    controller = application.getControllerForElementAndIdentifier(form, 'image-description')
    window.fetch = jest.fn()
    jest.useFakeTimers()
  })

  afterEach(() => {
    controller.disconnect()
    application.stop()
    document.body.innerHTML = ''
    jest.useRealTimers()
    jest.restoreAllMocks()
    delete window.fetch
  })

  async function begin() {
    controller.select([image()])
    await jest.advanceTimersByTimeAsync(0)
  }

  it('uploads a dropped image with CSRF and replaces text only after completion, without submitting search', async () => {
    const submit = jest.fn()
    form.addEventListener('submit', submit)
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'running' })).mockResolvedValueOnce(completed())
    const drop = new Event('drop', { bubbles: true, cancelable: true })
    Object.defineProperty(drop, 'dataTransfer', { value: { files: [image()] } })
    textarea.dispatchEvent(drop)
    await jest.advanceTimersByTimeAsync(0)
    expect(drop.defaultPrevented).toBe(true)
    expect(textarea.value).toBe('My original text')
    expect(controller.statusTarget.textContent).toContain('queued')
    const [url, options] = window.fetch.mock.calls[0]
    expect(url).toBe('/search/image-descriptions')
    expect(options).toMatchObject({ method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-Token': 'test-csrf' } })
    expect(options.body.get('image')).toBeInstanceOf(File)
    await jest.advanceTimersByTimeAsync(1000)
    expect(controller.statusTarget.textContent).toContain('Describing image')
    await jest.advanceTimersByTimeAsync(1000)
    expect(textarea.value).toBe('A cotton shirt.')
    expect(textarea.readOnly).toBe(false)
    expect(controller.statusTarget.textContent).toBe('Check the description, then search.')
    expect(submit).not.toHaveBeenCalled()
    expect(jest.getTimerCount()).toBe(0)
  })

  it('supports the native file picker without posting that file during the later search', async () => {
    window.fetch.mockResolvedValueOnce(accepted())
    const file = controller.fileTarget
    Object.defineProperty(file, 'files', { value: [image()] })
    file.dispatchEvent(new Event('change', { bubbles: true }))
    await jest.advanceTimersByTimeAsync(0)
    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(new FormData(form).has('image')).toBe(false)
  })

  it('blocks search before existing validation can hide or submit the form, but leaves classic search alone', async () => {
    window.fetch.mockResolvedValueOnce(accepted())
    await begin()
    const nextHandler = jest.fn()
    form.addEventListener('submit', nextHandler)
    const event = new Event('submit', { bubbles: true, cancelable: true })
    form.dispatchEvent(event)
    expect(event.defaultPrevented).toBe(true)
    expect(nextHandler).not.toHaveBeenCalled()
    expect(document.activeElement).toBe(controller.cancelTarget)
    textarea.disabled = true
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
    expect(nextHandler).toHaveBeenCalledTimes(1)
  })

  it('cancels safely and ignores a late completion', async () => {
    let finish
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementationOnce(() => new Promise(resolve => { finish = resolve }))
    await begin()
    await jest.advanceTimersByTimeAsync(1000)
    const signal = window.fetch.mock.calls[1][1].signal
    controller.cancel()
    expect(signal.aborted).toBe(true)
    finish(completed())
    await jest.advanceTimersByTimeAsync(0)
    expect(textarea.value).toBe('My original text')
    expect(controller.statusTarget.textContent).toContain('cancelled')
    expect(document.activeElement).toBe(textarea)
    expect(jest.getTimerCount()).toBe(0)
  })

  it('never overwrites user edits, even when they return to the original text', async () => {
    let finish
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementationOnce(() => new Promise(resolve => { finish = resolve }))
    await begin()
    await jest.advanceTimersByTimeAsync(1000)
    textarea.value = 'Changed text'
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
    textarea.value = 'My original text'
    finish(completed())
    await jest.advanceTimersByTimeAsync(0)
    expect(textarea.value).toBe('My original text')
    expect(controller.statusTarget.textContent).toContain('Your edits are kept')
  })

  it('ignores responses from an image superseded by a new selection', async () => {
    let first
    window.fetch.mockImplementationOnce(() => new Promise(resolve => { first = resolve })).mockResolvedValueOnce(accepted()).mockResolvedValueOnce(completed('A newer image.'))
    await begin()
    await begin()
    first(accepted())
    await jest.advanceTimersByTimeAsync(1000)
    expect(textarea.value).toBe('A newer image.')
    expect(window.fetch).toHaveBeenCalledTimes(3)
  })

  it('shows recovery and only retries an ambiguous POST after an explicit action', async () => {
    window.fetch.mockRejectedValueOnce(new TypeError('network disconnected'))
    await begin()
    await jest.advanceTimersByTimeAsync(10000)
    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(textarea.value).toBe('My original text')
    expect(controller.errorTarget.hidden).toBe(false)
    expect(controller.retryTarget.hidden).toBe(false)
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(completed())
    controller.retryTarget.click()
    expect(document.activeElement).toBe(controller.cancelTarget)
    await jest.advanceTimersByTimeAsync(1000)
    expect(textarea.value).toBe('A cotton shirt.')
    expect(controller.errorTarget.hidden).toBe(true)
  })

  it('handles backend upload rejection with actionable local copy', async () => {
    window.fetch.mockResolvedValueOnce(reply({ errors: [{ detail: '<private provider detail>' }] }, 415))
    await begin()
    expect(controller.errorTarget.textContent).toContain('Choose another image')
    expect(controller.errorTarget.textContent).not.toContain('private')
    expect(controller.retryTarget.hidden).toBe(true)
  })

  it('offers reload recovery for a non-JSON CSRF rejection without silently resubmitting', async () => {
    window.fetch.mockResolvedValueOnce({ ...reply({}, 422), headers: { get: () => 'text/html' } })
    await begin()
    expect(controller.errorTarget.textContent).toContain('reload the page')
    expect(controller.errorTarget.textContent).toContain('Copy your description')
    expect(textarea.value).toBe('My original text')
    expect(window.fetch).toHaveBeenCalledTimes(1)
  })

  it('stops after a failed job and preserves the description', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockResolvedValueOnce(reply({ status: 'failed' }))
    await begin()
    await jest.advanceTimersByTimeAsync(1000)
    expect(textarea.value).toBe('My original text')
    expect(controller.errorTarget.hidden).toBe(false)
    expect(jest.getTimerCount()).toBe(0)
  })

  it('does not overlap polls and enforces the fixed sixty-second deadline even for a hanging request', async () => {
    window.fetch.mockResolvedValueOnce(accepted()).mockImplementationOnce(() => new Promise(() => {}))
    await begin()
    await jest.advanceTimersByTimeAsync(59000)
    expect(window.fetch).toHaveBeenCalledTimes(2)
    await jest.advanceTimersByTimeAsync(1000)
    expect(window.fetch.mock.calls[1][1].signal.aborted).toBe(true)
    expect(controller.errorTarget.textContent).toContain('took too long')
    expect(jest.getTimerCount()).toBe(0)
  })

  it('cleans up requests and timers on disconnect', async () => {
    window.fetch.mockResolvedValueOnce(accepted())
    await begin()
    const signal = window.fetch.mock.calls[0][1].signal
    controller.disconnect()
    await jest.advanceTimersByTimeAsync(60000)
    expect(signal.aborted).toBe(true)
    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(jest.getTimerCount()).toBe(0)
  })

  it('does not follow an untrusted cross-origin poll URL', async () => {
    window.fetch.mockResolvedValueOnce(reply({ poll_url: 'https://example.com/search/image-descriptions/123?token=grant' }, 202))
    await begin()
    await jest.advanceTimersByTimeAsync(1000)
    expect(window.fetch).toHaveBeenCalledTimes(1)
    expect(controller.errorTarget.hidden).toBe(false)
  })

  it('validates multiple files and the size limit without uploading', () => {
    controller.select([image(), image()])
    expect(controller.errorTarget.textContent).toContain('one product image')
    const large = image()
    Object.defineProperty(large, 'size', { value: 15 * 1024 * 1024 + 1 })
    controller.select([large])
    expect(controller.errorTarget.textContent).toContain('15MB')
    expect(window.fetch).not.toHaveBeenCalled()
  })
})
