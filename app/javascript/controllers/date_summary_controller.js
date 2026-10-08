import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['summary']

  hide() {
    if (this.hasSummaryTarget) this.summaryTarget.hidden = true
  }
}
