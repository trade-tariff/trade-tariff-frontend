# Ruby, Rails, and GOV.UK Frontend Style Guide

This guide is for contributors and reviewers opening PRs in Trade Tariff Frontend. It complements the repo README, PR template, GOV.UK Design System guidance, and existing code patterns.

## PR Review Baseline

Every PR should make it easy to answer:

- What user need or maintenance need does this serve?
- Which route, controller, model/API entity, presenter/helper, view, asset, and spec files changed?
- Does it change legally significant tariff information or how traders interpret it?
- Does it change accessibility, copy, validation, analytics, service navigation, or responsive layout?
- What test and manual evidence proves the change?

Use `BAU` as the ticket when there is no Jira story.

## Ruby and Rails

- Follow the existing Rails conventions before introducing new patterns.
- Prefer small, named methods when they clarify domain decisions in measures, quotas, rules of origin, Green Lanes, or search.
- Keep controllers thin: load data, handle redirects/errors, and choose views. Move display decisions to presenters/helpers and form validation to form objects.
- Do not add explicit `require` statements for application constants in normal Rails app code when Zeitwerk can autoload them. Initializers and boot-time `lib/` files can require dependencies where needed.
- Prefer keyword arguments for option-heavy methods.
- Prefer `Data.define` for simple immutable value objects. Do not introduce `Struct`.
- Avoid `OpenStruct` in new code.
- Keep API-backed model changes aligned with `ApiEntity` and backend JSON:API contracts.
- Use route helpers rather than hard-coded internal URLs in Ruby code and templates.
- Keep environment variable additions documented in the PR and make defaults explicit where safe.

## Views and GOV.UK Components

- Prefer `govuk-components` helpers, `govuk_design_system_formbuilder`, and existing shared partials before custom markup.
- Use GOV.UK component classes and macros as documented; do not approximate component HTML by memory.
- Treat labels, legends, hints, error messages, page titles, breadcrumbs, back links, and focus order as behaviour.
- Put one primary `<h1>` on a page and keep page title text aligned with the visible heading.
- Use fieldsets and legends for grouped controls.
- Render validation errors through GOV.UK error summaries and field-level errors.
- Keep links descriptive outside their surrounding sentence.
- Avoid custom ARIA unless native HTML or GOV.UK component semantics cannot express the interaction.
- Keep progressive enhancement intact: critical content and form submissions must work without JavaScript where practical.

## Sass and Frontend Assets

- Use GOV.UK Sass variables, mixins, spacing, typography, and colour helpers before custom values.
- Keep Sass scoped to a component, journey, or existing module under `app/assets/stylesheets/src/`.
- Do not use colour alone to convey meaning.
- Check small screens, print styles where relevant, and long tariff descriptions or commodity codes.
- Avoid broad overrides of GOV.UK classes unless the change is intentional, tested, and called out in the PR.

## JavaScript

- Keep JavaScript as progressive enhancement.
- Use existing Stimulus/controller patterns and importmap entrypoints.
- Add JavaScript tests under `spec/javascript/` for behaviour that can regress without a full browser spec.
- Use accessibility tests or feature specs when JavaScript changes focus management, disclosure, autocomplete, modals, or keyboard behaviour.

## Testing

- Prefer request specs for route/controller behaviour.
- Use feature specs for end-to-end user journeys and visible page behaviour.
- Use view specs for complex templates or conditional rendering.
- Use helper specs for helper-only behaviour.
- Use model/form specs for validation, parsing, and API-backed object behaviour.
- Use VCR/WebMock fixtures for backend API interactions and keep fixtures focused on the scenario.
- Compile assets before running specs that depend on views or browser rendering.

Useful commands:

```sh
bin/rails assets:precompile
bundle exec rspec
yarn jest
yarn axxy
bundle exec brakeman
pre-commit run --all-files --show-diff-on-failure
```

## Risk Heuristics

Generally low risk:

- copy changes that do not alter legal meaning
- isolated GOV.UK component updates with equivalent behaviour
- tests and documentation
- small refactors with unchanged public behaviour

Needs team discussion:

- search result behaviour, autocomplete, or navigation changes
- changes to commodity, measure, duty, quota, or certificate display
- backend API call changes
- broad Sass/layout changes
- error pages, header, footer, cookies, auth/session, analytics, or accessibility changes

Requires explicit senior approval:

- legally significant tariff interpretation changes
- declarable goods journey changes
- auth/session or credential handling changes
- production infrastructure or deployment behaviour changes that are hard to roll back
- changes that put WCAG 2.2 AA or GOV.UK Design System conformance at risk
