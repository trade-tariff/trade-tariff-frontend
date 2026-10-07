import { Application } from '@hotwired/stimulus'
import DateSummaryController from '../../../app/javascript/controllers/date_summary_controller'

const settle = () => new Promise(resolve => setTimeout(resolve, 0))

describe('DateSummaryController', () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <form data-controller="date-summary" data-action="input->date-summary#hide change->date-summary#hide">
        <p data-date-summary-target="summary">Using today's date</p>
        <details open><summary>Change date</summary><input name="day" value="7"></details>
      </form>`
    application = Application.start()
    application.register('date-summary', DateSummaryController)
    await settle()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  it.each(['input', 'change'])('hides the stale summary after %s and closing the date fields', event => {
    const summary = document.querySelector('p')
    const input = document.querySelector('input')
    expect(summary.hidden).toBe(false)

    input.value = '22'
    input.dispatchEvent(new Event(event, { bubbles: true }))
    document.querySelector('details').open = false

    expect(summary.hidden).toBe(true)
    expect(new FormData(document.querySelector('form')).get('day')).toBe('22')
  })
})
