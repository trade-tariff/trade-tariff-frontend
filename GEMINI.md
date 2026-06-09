# Gemini Instructions

Use `docs/README.md` as the first repository map and `docs/architecture/README.md` for runtime boundaries.

This is a Rails 8 frontend for the Trade Tariff service. It renders public GOV.UK journeys and consumes Trade Tariff Backend APIs through Faraday-backed API entities. UK/XI service behaviour is selected through URL/service routing and `TradeTariffFrontend::ServiceChooser`.

Before changing code:

- Identify the route, controller, model/API entity, presenter/helper, view partial, asset, and tests involved.
- Verify generated explanations against source files.
- Prefer request specs for route/controller behaviour; do not expand legacy controller specs where a request spec is the better fit.
- Use feature specs for full journeys, view specs for complex templates, helper specs for isolated helper logic, and JavaScript specs for Stimulus/browser behaviour.
- Prefer `govuk-components`, `govuk_design_system_formbuilder`, and existing shared partials before custom GOV.UK markup.
- Treat accessibility, validation copy, page titles, hints, labels, focus order, and service navigation state as behaviour.
- Do not add explicit `require` statements for application constants in normal Rails app code when Zeitwerk can autoload them.
- Read the relevant docs before editing commodity display, measures, duties, quotas, rules of origin, Green Lanes, subscriptions, auth/session handling, or backend API calls.
- Run project commands directly by default. If you use Nix/direnv locally, `direnv exec <repo-path> <command>` is also fine.
- Use `rg` for code search.

Before opening a PR:

- Use `.github/pull_request_template.md` as the canonical risk decision tree.
- Fill in the Risk section and apply exactly one matching GitHub label: `low-risk` for green, `medium-risk` for amber, or `high-risk` for red.
- Treat GOV.UK copy/content changes, GOV.UK component updates with no behaviour change, tests-only changes, dependency bumps with no API changes, additive config with safe defaults, covered refactors with no behaviour change, read-only observability, Terraform changes with no resource recreation, and static asset changes with no layout impact as typical `low-risk` changes.
- Treat page layout or navigation changes affecting many journeys, commodity or tariff presentation changes, backend/admin API calls, live feature flags, error page, accessibility markup, service header/footer, search UI, cross-browser Sass/CSS, networking, security group, IAM, resource replacement, CI/CD, deployment ordering, and route/action/partial deprecation changes as typical `medium-risk` changes that need a team conversation before merging.
- Treat legally significant content, declarable goods or trader-facing regulatory journeys, identity/authentication integration, hard-to-rollback production AWS, secrets or credential handling, significant architecture, and GOV.UK service compliance, WCAG 2.2 AA, or design-system conformance changes as typical `high-risk` changes that require explicit approval from Thor or Neil.
- If the risk rating changes during review, remove the old risk label and apply the new one.

Useful docs:

- `docs/development-and-delivery.md`
- `docs/style-guide.md`
- `docs/architecture/system-overview.md`
- `docs/architecture/request-routing.md`
- `docs/architecture/backend-api-client.md`
- `docs/architecture/duty-calculator.md`
- `docs/architecture/frontend-rendering.md`
