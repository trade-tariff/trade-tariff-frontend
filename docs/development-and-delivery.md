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
INTERACTIVE_SEARCH=false
PARCEL_GIFT_JOURNEY=true
```

The exact values `true` and `false` take precedence over Flagsmith. Unset, empty or
other values leave Flagsmith and the existing default in control. Service
restrictions still apply. A registration can disable automatic overrides with
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

### Approved fork deployments

The frontend-only and full-stack development workflows use the shared tools
authorization action. It reads
[the central account policy](https://github.com/trade-tariff/trade-tariff-tools/blob/main/.github/approved-fork-deployers.json)
from tools `main`. Add an external contributor's GitHub login under
`trade-tariff-frontend` through a reviewed tools PR. Approval for another
repository does not grant frontend approval.

A repository writer adds `needs-deployment` for the frontend alone or
`needs-full-deployment` for the full stack. An approved contributor can then
deploy later updates from their own fork. Both the original triggering account
and the account that reruns a job must be approved for this repository or have
repository write access. Unlisted forks cannot deploy through these workflows.
Full-stack deployment uses the approved frontend commit and the normal refs for
backend, admin and identity. The policy approves fork-code sources; it does not
filter these supporting apps.

The authorization job runs trusted code without deployment secrets or OIDC
permission. After authorization, the deployment jobs use the exact PR commit.
**Approval trusts that account's build and Terraform code with the existing
development CI credentials.** It does not make fork code a sandbox. Review changes
to build scripts and Terraform before adding the deployment label. Remove the
label to stop future automatic deployments. Cancel an active run separately.
Development builds push images to the shared production-account ECR repository.
The account list does not reduce the existing IAM role's permissions.

Repository writers can still deploy upstream branches and run the workflow
manually from `main`. The manual `sha` input accepts a commit or ref and resolves
it to an exact commit before deployment. The external account policy does not grant
manual dispatch access, organisation membership or personal AWS credentials.
Preview, staging and production workflows do not use this policy.

Frontend-only development deployment does not run end-to-end tests. Full-stack
deployment runs the existing tariff and accessibility checks. Check the deployed
commit and changed journey on the development site. If rollback is needed, a repository
writer runs the manual development workflow with the previous deployed commit.

Frontend changes can affect GOV.UK compliance, accessibility, SEO metadata, analytics, service navigation, and user-visible tariff interpretation. Call out those effects explicitly in PRs.
