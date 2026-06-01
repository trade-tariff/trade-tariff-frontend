# Copilot Instructions

Use `docs/README.md` and `docs/architecture/README.md` before suggesting broad changes.
Use `docs/development-and-delivery.md` and `docs/style-guide.md` for PR, Rails, test, and GOV.UK Frontend conventions.

Project facts:

- Rails 8 frontend application.
- Public GOV.UK Trade Tariff web journeys.
- Backend API access through Faraday clients, `ApiEntity`, and API-backed models.
- UK/XI service context is selected by routing filters and `TradeTariffFrontend::ServiceChooser`.
- Assets use Propshaft, cssbundling-rails, importmap, Stimulus, Turbo, Sass, and GOV.UK Frontend.

Guidance:

- Keep suggestions narrowly scoped to the requested change.
- Prefer existing controller, form, presenter, helper, shared partial, and GOV.UK component patterns.
- Prefer request specs for route/controller behaviour and feature specs for full journeys.
- Do not expand legacy controller specs where request specs would cover the behaviour better.
- Treat accessibility, validation copy, labels, hints, page titles, focus order, and responsive behaviour as first-class requirements.
- Prefer `govuk-components`, `govuk_design_system_formbuilder`, and GOV.UK Sass helpers before custom markup or CSS.
- Do not add explicit `require` statements for application constants in normal Rails app code when Zeitwerk can autoload them.
- Treat commodity display, measures, duties, quotas, Green Lanes, rules of origin, subscriptions, auth/session handling, and backend API calls as high-risk.
- For duty calculator changes, read `docs/architecture/duty-calculator.md` and verify claims against `app/models/duty_calculator/`, `app/services/duty_calculator/`, and `config/routes/duty_calculator.rb`.
- Verify generated documentation or Code Wiki output against source files before relying on it.
