# System Overview

Trade Tariff Frontend is the public web application for the UK Trade Tariff service. It renders GOV.UK-styled user journeys for search, browse, commodity detail pages, measures, quota lookups, rules of origin, Green Lanes, exchange rates, news, feedback, subscriptions, and related tools.

## Runtime Shape

- Rails 8 application running on Puma.
- Backend data comes from Trade Tariff Backend through Faraday clients.
- API-backed models include `ApiEntity` rather than Active Record persistence.
- UK and XI service mode is selected through route filtering and `TradeTariffFrontend::ServiceChooser`.
- Redis is used in production.
- Assets are built with Propshaft, cssbundling-rails, importmap, Stimulus, Turbo, Sass, and GOV.UK Frontend.

## Main Code Areas

- `app/controllers/` maps web requests to API-backed models, forms, presenters, and views.
- `app/models/` contains API-backed domain objects and local form/session models.
- `app/forms/` contains form objects for search and multi-step journeys.
- `app/presenters/` and `app/decorators/` prepare display-specific behaviour for templates.
- `app/helpers/` contains view helpers, including GOV.UK-specific helpers.
- `app/views/` contains ERB templates and shared partials.
- `app/assets/stylesheets/` contains GOV.UK imports plus service-specific Sass.
- `app/javascript/` contains JavaScript entrypoints and controllers.
- `spec/` contains RSpec, Capybara, VCR/WebMock, view/helper specs, and JavaScript tests.

## High-Risk Areas

Treat these areas as high risk and verify behaviour with source-backed tests and manual evidence:

- commodity, heading, subheading, and section rendering
- measure, duty, quota, certificate, and preference display
- rules of origin and Green Lanes journeys
- search and autocomplete behaviour
- backend API request/response handling
- subscriptions, cookies, auth/session handling, and feedback
- accessibility and GOV.UK Design System conformance
