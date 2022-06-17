require('../src/javascripts/step-by-step-nav.js');
import { Controller } from "stimulus"

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
