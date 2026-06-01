# Agent Instructions

Use these instructions for Codex and other agentic coding tools working in this repository.

## Start Here

Read these first:

- `docs/README.md`
- `docs/architecture/README.md`
- `docs/development-and-delivery.md`
- `docs/style-guide.md`
- `README.md`

The application is a Rails 8 frontend for the Trade Tariff service. It renders the public web journeys, talks to Trade Tariff Backend APIs with Faraday, and runs in UK or XI service mode through URL/service selection.

## Working Rules

- Keep scope tight and prefer the existing Rails, presenter, helper, and partial patterns.
- Verify generated or AI-suggested claims against source code and tests.
- Do not add explicit `require` statements for application constants in normal Rails app code when Zeitwerk can autoload them. Initializers and `lib/` boot paths can be different; follow existing patterns.
- Prefer request specs for route/controller behaviour. Do not expand legacy controller specs where a request spec would cover the behaviour better.
- Use feature specs for full user journeys, view specs for complex templates, helper specs for helper-only logic, and JavaScript specs for Stimulus/browser behaviour.
- Treat GOV.UK Frontend, accessibility, page titles, labels, hints, validation errors, and focus order as part of the behaviour, not cosmetic detail.
- Prefer `govuk-components`, `govuk_design_system_formbuilder`, and existing shared partials before hand-rolling GOV.UK markup.
- Keep Sass changes narrow. Use GOV.UK Sass variables, mixins, spacing, and typography before adding custom values.
- Run project commands directly by default. If you use Nix/direnv locally, `direnv exec <repo-path> <command>` is also fine.
- Use `rg` for code search.
- Treat commodity display, measures, duties, quotas, rules of origin, Green Lanes, subscriptions, auth/session handling, and backend API calls as high-risk areas.

## Key Entry Points

- Routes: `config/routes.rb`, `config/routes/duty_calculator.rb`
- Application shell: `app/views/layouts/application.html.erb`, `app/views/layouts/_base.html.erb`
- Backend clients: `config/initializers/backend.rb`, `app/services/client_builder.rb`, `lib/api_entity.rb`
- Service selection: `lib/routing_filter/service_path_prefix_handler.rb`, `lib/trade_tariff_frontend/service_chooser.rb`
- Controllers: `app/controllers/`
- API-backed models: `app/models/`
- Presenters/decorators: `app/presenters/`, `app/decorators/`
- Forms: `app/forms/`
- GOV.UK helpers and shared partials: `app/helpers/`, `app/views/shared/`
- Assets and JavaScript: `app/assets/stylesheets/`, `app/javascript/`
- Tests: `spec/requests/`, `spec/features/`, `spec/views/`, `spec/helpers/`, `spec/javascript/`
- CI and deployment: `.github/workflows/`

## PR Notes

- Use the PR template in `.github/pull_request_template.md`.
- Use `BAU` as the ticket prefix when there is no Jira story.
- Include risk, manual evidence, accessibility impact, and test commands when changing user-facing pages.
