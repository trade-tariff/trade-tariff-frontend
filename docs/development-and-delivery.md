# Development and Delivery

This page summarises team and platform conventions for this repository. Verify current implementation in source, tests, and workflow files before changing behaviour.

## Local Development

The repo README is the source of truth for setup. In normal local development you need:

- Ruby and Bundler matching `.ruby-version`.
- Node and Yarn.
- Chrome or Chrome for Testing for browser-based specs.
- A Trade Tariff Backend API endpoint, usually configured through `API_SERVICE_BACKEND_URL_OPTIONS`.
- Pre-commit hooks installed and enabled.

Useful commands:

```sh
bin/setup
bin/rails start
bin/rails assets:precompile
bundle exec rspec
yarn jest
yarn axxy
```

`bin/rails assets:precompile` is required before many specs because view and feature specs depend on compiled assets.

## Pull Requests

Use `.github/pull_request_template.md`. Include:

- what changed and why
- the Jira ticket, or `BAU` when there is no story
- risk level and reason
- test commands and results
- manual evidence for visible journeys
- accessibility impact for UI changes
- backend API, environment variable, or deployment implications

Follow the existing team convention of branch names that describe the work or ticket, for example `AI-123-short-description` or `BAU-short-description`.

## Checks

Current CI checks are defined in `.github/workflows/ci.yml`:

- Brakeman
- pre-commit hooks
- asset precompile
- RSpec

Other workflows cover CodeQL, deployment, preview environments, labels, and service stop/start operations. Check `.github/workflows/` before changing CI/CD or deployment behaviour.

## Deployments

Deployment is handled by GitHub Actions. Development, staging, production, and preview environment workflows live in `.github/workflows/`.

Frontend changes can affect GOV.UK compliance, accessibility, SEO metadata, analytics, service navigation, and user-visible tariff interpretation. Call out those effects explicitly in PRs.
