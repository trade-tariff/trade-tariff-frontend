# Pin npm packages by running ./bin/importmap
pin 'application'

# @amplitude/engagement-browser 1.0.12, loaded only after consent and GTM readiness.
pin '@amplitude/engagement-browser', to: 'amplitude-engagement.js', preload: false

pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'

pin 'govuk-frontend' # @6.4.0
pin 'mark.js' # @8.11.1
pin 'jquery' # @4.0.0
pin 'accessible-autocomplete' # @3.0.1
pin 'debounce' # @3.0.0
pin 'js-cookie' # @3.0.8

pin_all_from 'app/javascript/src', to: 'src'
pin_all_from 'app/javascript/controllers', under: 'controllers'
