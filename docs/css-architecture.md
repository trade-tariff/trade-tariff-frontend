# CSS And Sass Architecture

Use this file when changing Sass structure, selectors, print CSS, or stylesheet ownership.

## Layer Ownership

`app/assets/stylesheets/application.sass.scss` imports Sass by ownership layer. Keep new partials in the matching directory:

- `settings/`: design tokens, variables, shared colours, breakpoints, and values that other layers read, such as `settings/_colors.scss`.
- `tools/`: Sass functions and mixins that emit no CSS by themselves, such as `tools/_functions.scss`.
- `base/`: global element defaults, GOV.UK extension points, and legacy app-wide fixes.
- `overrides/`: deliberate GOV.UK or third-party component overrides, kept narrow and named for the thing being overridden.
- `utilities/`: tiny reusable utility classes with intentionally global behaviour.
- `patterns/`: reusable multi-component patterns such as common table treatments.
- `components/`: reusable app components that can appear on more than one journey.
- `journeys/`: page or journey-specific layout and presentation.
- `print/`: print-only base rules and print deltas over screen components.
- `vendor/`: copied or adapted third-party styles. Avoid local edits where possible.

Keep the entrypoint order deliberate: settings and tools first, then base, overrides, utilities, patterns, components, and journeys. Do not make one component depend on another component's import order; move shared prerequisites into `settings/`, `tools/`, `base/`, or `patterns/`.

## Component CSS

Use `components/` when the CSS owns one reusable UI concept that can appear on more than one page or journey, for example cards, related navigation, feature panels, or downloadable documents.

Component CSS should:

- target app-owned classes rather than IDs;
- stay close to the component markup or helper that emits those classes;
- avoid depending on page-specific parent selectors;
- expose variants through explicit modifier classes instead of new one-off descendants.

## Journey CSS

Use `journeys/` when the styles are specific to one route, feature area, or user journey. Examples include search, Rules of Origin, exchange rates, and MyOTT.

Journey CSS should be scoped to a route or journey parent class where practical. If a rule becomes useful outside that journey, move it to `components/`, `patterns/`, or `utilities/` rather than importing journey CSS elsewhere.

## Base, Utilities, And Patterns

Use `base/` only for global HTML defaults, GOV.UK extension points, and compatibility fixes that genuinely apply across the service. Broad element selectors belong here or should not be added.

Use `utilities/` for tiny, explicit classes that are intentionally global. A utility should do one thing and should not encode journey-specific layout.

Use `patterns/` for reusable compositions that are broader than a single component but narrower than base CSS, such as common table treatments.

## Print CSS

Keep `print.sass.scss` as the print entrypoint. It should import print base rules, print-only utilities, and component print partials rather than carrying full component implementations inline.

Print partials should contain deltas over the screen component model. Shared component structure belongs with the screen component, and print partials should only describe what changes for printed output.

Prefer GOV.UK print utilities in markup for simple show/hide behaviour, for example `govuk-!-display-none-print`. Use custom print CSS when the rule is reusable, structural, or cannot be expressed with a GOV.UK utility.

Avoid duplicating complete screen components in print stylesheets. Extract shared Sass mixins or component structure first, then layer print deltas over the shared component.

## Change Rules

- Prefer moving shared prerequisites into `settings/`, `tools/`, or `base/` rather than making one component depend on another component's import order.
- Keep component CSS with reusable components and journey CSS with the journey that owns the markup.
- Avoid styling through IDs or broad global selectors. If app-owned markup needs styling, add or use a class while preserving IDs required for labels, anchors, JavaScript, or accessibility.
- Avoid new `!important` declarations. If one is unavoidable, keep it local, explain the competing rule, and cover the affected rendering in validation.
- Keep GOV.UK overrides explicit and narrow. Use GOV.UK Sass variables, mixins, spacing, and typography before adding custom values.
- Treat `print.sass.scss` as print overrides over the screen component model, not a second fork of component CSS.

## GOV.UK And Vendor Policy

Prefer GOV.UK Frontend, `govuk-components`, GOV.UK Sass helpers, and GOV.UK utility classes before custom CSS. Do not approximate GOV.UK component markup or override broad GOV.UK classes by default.

When a GOV.UK or vendor override is necessary:

- put it in `overrides/` unless it belongs to a local component wrapper;
- keep the selector as narrow as possible;
- call out the reason and validation in the PR;
- include representative page coverage when the override affects high-risk pages.

Copied or adapted third-party CSS belongs in `vendor/`. Local service behaviour should usually live outside `vendor/` so future upstream updates are easier to review.

## Verification

- For import reordering, selector moves, or shared-token extraction, run the CSS build and compare before/after rendering on affected pages.
- Use targeted screenshots for representative components, journeys, forms, tables, and footer/header areas touched by the cascade.
- If a Sass change affects high-risk commodity, measure, duty, quota, rules-of-origin, or service-header/footer surfaces, include representative visual evidence and the relevant specs/build commands in the PR.
