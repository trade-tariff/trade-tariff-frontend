import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

document.addEventListener('DOMContentLoaded', function () {
  jQuery('input[name=authenticity_token]').val($('meta[name=csrf-token]').attr('content'))
});

export { application }
