# Pin npm packages by running ./bin/importmap
pin 'application'

pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'

pin 'govuk-frontend' # @6.0.0
pin 'mark.js' # @8.11.1
pin "jquery" # @4.0.0
pin 'accessible-autocomplete' # @3.0.1
pin 'debounce' # @2.2.0
pin 'js-cookie' # @3.0.5

pin_all_from 'app/javascript/src', to: 'src'
pin_all_from 'app/javascript/controllers', under: 'controllers'
