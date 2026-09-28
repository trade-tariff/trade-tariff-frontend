const ID = /^[a-zA-Z0-9-]{1,64}$/
const KEY = 'guidedSearchJourney'
const observations = new Map()

function readStore() {
  try {
    const parsed = JSON.parse(window.sessionStorage.getItem(KEY) || '{}')
    return parsed && typeof parsed === 'object' ? parsed : {}
  } catch {
    return {}
  }
}

function writeStore(value) {
  try {
    window.sessionStorage.setItem(KEY, JSON.stringify(value))
  } catch {
    // Telemetry must not break search.
  }
}

export function validId(value) {
  return typeof value === 'string' && ID.test(value) ? value : null
}

export function newId() {
  try {
    const minted = window.crypto?.randomUUID?.()
    if (validId(minted)) return minted
  } catch {
    // Fall through to a non-cryptographic telemetry id.
  }
  let id = ''
  for (let index = 0; index < 32; index += 1) id += Math.floor(Math.random() * 16).toString(16)
  return id
}

function field(form, name) {
  return form?.querySelector(`input[type="hidden"][name="${name}"]`) || null
}

export function readField(form, name) {
  return validId(field(form, name)?.value)
}

export function writeField(form, name, value) {
  if (!form || !validId(value)) return
  try {
    let input = field(form, name)
    if (!input) {
      input = document.createElement('input')
      input.type = 'hidden'
      input.name = name
      form.appendChild(input)
    }
    input.value = value
  } catch {
    // Telemetry must not break search.
  }
}

export function rememberJourney(journeyId) {
  const id = validId(journeyId)
  if (!id) return
  const store = readStore()
  if (store.journeyId === id) return
  writeStore({ ...store, journeyId: id })
}

export function currentJourney(form) {
  return readField(form, 'telemetry_journey_id') ||
    validId(document.querySelector('[data-guided-search-page-journey-id-value]')?.getAttribute('data-guided-search-page-journey-id-value')) ||
    validId(readStore().journeyId)
}

export function currentSubmission(form) {
  return readField(form, 'telemetry_submission_id') || validId(readStore().submissionId)
}

export function beginInitialJourney(form) {
  const journeyId = newId()
  const submissionId = newId()
  writeField(form, 'telemetry_journey_id', journeyId)
  writeField(form, 'telemetry_submission_id', submissionId)
  const store = readStore()
  writeStore({ ...store, journeyId, submissionId })
  return { journeyId, submissionId }
}

export function observationId(logicalKey) {
  if (!observations.has(logicalKey)) observations.set(logicalKey, newId())
  return observations.get(logicalKey)
}

export function eventUrlFrom(element) {
  if (!element) return null
  return element.getAttribute('data-guided-search-event-url') ||
    element.getAttribute('data-interactive-question-event-url-value') ||
    element.getAttribute('data-guided-search-page-event-url-value') ||
    null
}

export function postJourneyEvent(url, payload) {
  if (!url) return
  try {
    const body = {}
    Object.entries(payload).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') body[key] = value
    })
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    window.fetch(url, {
      method: 'POST',
      keepalive: true,
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken },
      body: JSON.stringify(body),
    }).catch(() => {})
  } catch {
    // Telemetry must not break search.
  }
}
