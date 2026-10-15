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

Registered feature flags automatically accept an environment override using the
uppercase flag name. Edit `.env.development`, then restart Rails:

```dotenv
HYBRID_SEARCH=true
INTERACTIVE_SEARCH=false
PARCEL_GIFT_JOURNEY=true
```

The `hybrid_search` flag is off by default outside development.
`.env.development` sets `HYBRID_SEARCH=true` for all local classic searches.
The flag switches classic search and autocomplete to the internal API, including
heading and chapter descriptions. Autocomplete selections use the goods
nomenclature SID returned by that API, not public V2 suggestion-row IDs. The
backend must support these options before the flag is enabled. Its admin setting
still controls the enabled retrieval methods.

For a per-browser UK demo, visit `/hybrid-search-demo`. This opts the browser
session into `hybrid_search` and redirects to `/find_commodity` with the trusted
`hybrid-demo` label. In Flagsmith, keep the flag disabled by default and enable it
for a segment whose `hybrid_search` trait is true. The experiment adds a transient
opt-in trait; it does not force a disabled flag on or opt the browser into guided
search. Clear hybrid search on `/feature-flags` to leave the experiment.
The development override still applies after leaving the experiment.

Use `HYBRID_SEARCH=true` when a global environment override is needed.
`HYBRID_SEARCH=false` disables hybrid search even for experiment participants.

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
