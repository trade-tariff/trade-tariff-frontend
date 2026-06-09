# Request Routing

The main route map is `config/routes.rb`. Duty calculator routes are split into `config/routes/duty_calculator.rb` and loaded with `draw('duty_calculator')`.

## Service Context

The app supports UK and XI service contexts. Service context affects backend API host selection, currency, page styling, and service-specific routes.

Key files:

- `lib/routing_filter/service_path_prefix_handler.rb`
- `lib/trade_tariff_frontend/service_chooser.rb`
- `config/routes.rb`
- `app/helpers/service_helper.rb`

`TradeTariffFrontend::ServiceChooser` reads `API_SERVICE_BACKEND_URL_OPTIONS`, tracks the current service in thread-local state, and returns the appropriate Faraday client.

## Route Groups

Important route groups in `config/routes.rb`:

- static help, privacy, terms, cookies, tools, news, and glossary pages
- search, suggestions, A-Z, browse, sections, chapters, headings, subheadings, and commodities
- measure type preference code pages
- additional code, certificate, footnote, quota, chemical, and simplified procedural value searches
- MyOTT subscription journeys
- enquiry form journey
- rules of origin journey
- Green Lanes simplified processes eligibility journey
- exchange rates, available only in UK service mode
- health checks, CSP reports, errors, redirects, and catch-all 404 handling

## Testing Routing Changes

For route/controller behaviour, prefer request specs under `spec/requests/`. Use concrete paths or route helpers. Add feature specs when the change affects a complete user journey or visible navigation state.
