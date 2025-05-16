import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!this.userInUk())
      this.removeUkOnlyContent()
  }

  removeUkOnlyContent() {
    this.element.remove()
  }

  userInUk() {
    return this.timeZone() == 'Europe/London'
  }

  timeZone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone
  }
}
