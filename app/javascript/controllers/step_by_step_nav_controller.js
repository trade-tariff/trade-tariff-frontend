
import { Controller } from "@hotwired/stimulus"
import 'step-by-step-nav'

export default class extends Controller {
  connect() {
    this.initStepByStepNav()
  }

  initStepByStepNav() {
    this.stepByStepNavigation = new GOVUK.Modules.AppStepNav()
    this.stepByStepNavigation.start(this.jqueriedElement())
  }

  jqueriedElement() {
    return window.jQuery(this.element)
  }
}
