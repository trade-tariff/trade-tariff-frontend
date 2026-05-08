## What:
<!-- A brief description of what this PR does -->

## Why:
<!-- The reasoning or context behind this change -->

## Ticket:
<!-- Link to the relevant Jira/ticket, or 'N/A' if not applicable -->

## Risk:
**Risk level:** 🟢 / 🟠 / 🔴 <!-- delete as appropriate -->

**Reason for rating:**
<!-- One or two sentences explaining your assessment, especially for Amber or Red -->

───────────────────────────────────────────────────

Rate the overall risk of deploying this change:

🟢 Green  – Low risk. Good to go, standard review applies.

🟠 Amber  – Medium risk. Socialise with the team before merging.

🔴 Red    – High risk. Requires explicit approval from Thor or Neil before merging.

───────────────────────────────────────────────────

🟢 GREEN – things that are typically low risk:
───────────────────────────────────────────────────
- Copy or content changes to GOV.UK Frontend components (labels, hint text, page titles)
- Adding or updating GOV.UK Design System components with no behaviour change
- New tests or improved test coverage with no production code changes
- Dependency bumps with no API changes (minor/patch gems, npm packages)
- Config/env var additions that are purely additive and have safe defaults
- Refactors with full test coverage and no behaviour change
- Adding or updating CloudWatch alarms or dashboards (read-only observability)
- Terraform formatting or variable renaming with no resource recreation
- Static asset changes (images, fonts, stylesheets) with no layout impact

🟠 AMBER – things that need a team conversation first:
───────────────────────────────────────────────────
- Changes to page layout or navigation that affect all or many user journeys
- Modifications to how commodity data or tariff information is presented to traders
- New or modified API calls to the backend or admin services
- Adding or changing feature flags that affect live user journeys
- Changes to error pages, accessibility markup, or GOV.UK service header/footer
- Search UI changes (autocomplete behaviour, result rendering, filter logic)
- Significant Sass/CSS changes that could affect rendering across browsers or screen sizes
- Infrastructure changes that alter networking, security groups, or IAM permissions in non-production first
- Terraform changes that will cause a resource replacement (check plan output carefully)
- Changes to CI/CD pipeline steps or deployment order dependencies
- Removing or deprecating a route, controller action, or view partial still in use elsewhere

🔴 RED – requires explicit approval from Thor or Neil:
───────────────────────────────────────────────────
- Changes to how legally significant content is surfaced (trade remedies, prohibitions, licensing, sanctions)
- Modifications to the declarable goods flow or any trader-facing regulatory journey
- Any change to how the service integrates with the identity/authentication layer
- Changes to production AWS infrastructure that cannot be easily rolled back
- Secrets rotation or changes to how credentials are stored, scoped, or accessed
- Significant architectural shifts (e.g. new service boundaries, caching topology changes)
- Changes that affect GOV.UK service compliance, accessibility standards (WCAG 2.2 AA), or government design system conformance
