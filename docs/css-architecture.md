# CSS And Sass Architecture

Use this file when changing Sass structure, selectors, print CSS, or stylesheet ownership.

## Layer Ownership

`app/assets/stylesheets/application.sass.scss` imports Sass by ownership layer. Keep new partials in the matching directory:

- `settings/`: design tokens, variables, shared colours, breakpoints, and values that other layers read.
- `tools/`: Sass functions and mixins that emit no CSS by themselves.
- `base/`: global element defaults, GOV.UK extension points, and legacy app-wide fixes.
- `overrides/`: deliberate GOV.UK or third-party component overrides.
- `utilities/`: narrow reusable utility classes.
- `patterns/`: reusable multi-component patterns such as common table treatments.
- `components/`: reusable app components that can appear on more than one journey.
- `journeys/`: page or journey-specific layout and presentation.
- `vendor/`: copied or adapted third-party styles.

## Change Rules

- Prefer moving shared prerequisites into `settings/`, `tools/`, or `base/` rather than making one component depend on another component's import order.
- Keep component CSS with reusable components and journey CSS with the journey that owns the markup.
- Avoid styling through IDs or broad global selectors. If app-owned markup needs styling, add or use a class while preserving IDs required for labels, anchors, JavaScript, or accessibility.
- Keep GOV.UK overrides explicit and narrow. Use GOV.UK Sass variables, mixins, spacing, and typography before adding custom values.
- Treat `print.sass.scss` as print overrides over the screen component model, not a second fork of component CSS.

## Verification

- For import reordering, selector moves, or shared-token extraction, run the CSS build and compare before/after rendering on affected pages.
- Use targeted screenshots for representative components, journeys, forms, tables, and footer/header areas touched by the cascade.
- If a Sass change affects high-risk commodity, measure, duty, quota, rules-of-origin, or service-header/footer surfaces, include representative visual evidence and the relevant specs/build commands in the PR.
