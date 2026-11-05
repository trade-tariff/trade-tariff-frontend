# Development and Delivery

This page summarises team and platform conventions for this repository. Verify current implementation in source, tests, and workflow files before changing behaviour.

## Local Development

The repo README is the source of truth for setup. In normal local development you need:

- Ruby and Bundler matching `.ruby-version`.
- Node and Yarn.
- Chrome or Chrome for Testing for browser-based specs.
- A Trade Tariff Backend API endpoint, usually configured through `API_SERVICE_BACKEND_URL_OPTIONS`.
- Pre-commit hooks installed and enabled.

Follow [local setup](../README.md#run-locally) and [checks](../README.md#run-checks)
for the current commands. `bin/dev` starts Rails and the stylesheet watcher.
Compile stylesheets and test assets before running view and feature specs.
See [CONTRIBUTING.md](../CONTRIBUTING.md) for the fork workflow and accessibility checks.

### Feature flags

The parcel and gift journey and the revised duty calculator are standard journeys.
They do not require feature flags or browser opt-ins. `/hmrc-parcels` redirects to
`/parcels-and-gifts` for existing links.

Registered feature flags automatically accept an environment override using the
uppercase flag name. Edit `.env.development`, then restart Rails:

```dotenv
INTERACTIVE_SEARCH=false
```

Classic search and autocomplete always use the internal API in UK and XI.
Classic search requests hybrid retrieval, skips guided questions, and includes
heading and chapter descriptions. The backend admin setting still controls the
enabled retrieval methods. The backend must support these internal API options.
There is no hybrid search flag, browser opt-in, or environment override.

Autocomplete selections submit the goods nomenclature SID as `resource_id`.
Typed keyword options have no ID, and editing a query clears the selected ID.
The backend logs the submitted ID on `search_started` events for requests that
reach it. Guided search keeps its separate feature flag and question flow.

The exact values `true` and `false` take precedence over Flagsmith. Unset, empty or
other values leave Flagsmith and the existing default in control. Service
restrictions still apply. An explicit `false` disables a feature even for opted-in
browsers. A registration can disable automatic overrides with
`env: false`, for example `flagsmith_flag :feature_enabled?, name: :feature, env: false`.

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
- Jest
- asset precompile
- RSpec

Other workflows cover CodeQL, deployment, preview environments, labels, and service stop/start operations. Check `.github/workflows/` before changing CI/CD or deployment behaviour.

## Deployments

Deployment is handled by GitHub Actions. Development, staging, production, and preview environment workflows live in `.github/workflows/`.

Frontend changes can affect GOV.UK compliance, accessibility, SEO metadata, analytics, service navigation, and user-visible tariff interpretation. Call out those effects explicitly in PRs.
