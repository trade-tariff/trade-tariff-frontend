# Pin npm packages by running ./bin/importmap
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'

pin 'core-js/stable', to: 'https://ga.jspm.io/npm:core-js@3.42.0/stable/index.js'
pin 'govuk-frontend', to: 'https://cdn.jsdelivr.net/npm/govuk-frontend@5.10.0/+esm'

pin 'accessible-autocomplete' # @3.0.1
pin 'debounce' # @2.2.0
pin 'jquery' # @3.7.1
pin 'jquery-migrate' # @3.5.2
pin 'jquery.history'
pin 'jquery.nextid.min'
pin 'jquery.rovingtabindex.min'
pin 'jquery.tabs.min'
pin 'js-cookie' # @3.0.5
pin 'mark.js' # @8.11.1
pin 'popup'
pin 'select2' # @4.1.0

pin 'application'

pin_all_from 'app/javascript'
pin_all_from 'vendor/javascript', under: 'vendor'
