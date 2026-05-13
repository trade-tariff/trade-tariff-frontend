import { Application } from '@hotwired/stimulus'
import AnalyticsController from '../../../app/javascript/controllers/analytics_controller'

describe('AnalyticsController', () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <a
        id="developer-portal-tools-link"
        href="https://hub.dev.trade-tariff.service.gov.uk/"
        data-controller="analytics"
        data-action="click->analytics#track"
        data-analytics-event="developer_portal_tools_link_click">
        Developer Portal (opens in new tab)
      </a>
    `

    application = Application.start()
    application.register('analytics', AnalyticsController)
    await new Promise((resolve) => setTimeout(resolve, 0))
  })

  afterEach(() => {
    application.stop()
    delete window.dataLayer
  })

  it('pushes the configured event to the data layer on click', () => {
    window.dataLayer = []

    const link = document.querySelector('#developer-portal-tools-link')
    link.addEventListener('click', (event) => event.preventDefault())

    link.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }))

    expect(window.dataLayer).toEqual([
      {
        event: 'developer_portal_tools_link_click',
        link_id: 'developer-portal-tools-link',
        link_text: 'Developer Portal (opens in new tab)',
        link_url: 'https://hub.dev.trade-tariff.service.gov.uk/',
      },
    ])
  })

  it('does nothing when the data layer is absent', () => {
    const link = document.querySelector('#developer-portal-tools-link')
    link.addEventListener('click', (event) => event.preventDefault())

    expect(() => {
      link.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }))
    }).not.toThrow()
    expect(window.dataLayer).toBeUndefined()
  })
})
