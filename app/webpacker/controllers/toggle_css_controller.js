// Visit The Stimulus Handbook for more details
// https://stimulusjs.org/handbook/introduction
//
// This controller allows:
//
// <div data-controller="toggle-css"
//      data-toggle-css-class="some-class--open">
//   <a data-action="toggle-css#toggle"></h1>
//   <div data-toggle-target="container"></div>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ 'toggleable' ]
  static classes = [ 'toggle' ]

  toggle() {
    this.toggleableTarget.classList.toggle(this.toggleClass)
  }
}
