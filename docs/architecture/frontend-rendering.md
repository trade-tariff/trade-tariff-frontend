# Frontend Rendering

The frontend renders Rails ERB templates with GOV.UK Frontend, `govuk-components`, and `govuk_design_system_formbuilder`.

## Layout and Shell

`app/views/layouts/application.html.erb` defines the main document shell:

- GOV.UK template class and skip link
- application and print stylesheets
- importmap JavaScript tags
- cookie banner, header, service navigation, feedback banners, search form, footer, and GTM hooks

`app/views/layouts/_base.html.erb` supplies default page metadata, canonical URL, service navigation, and footer content.

## Views and Partials

Most visible behaviour lives in ERB partials under `app/views/`. Prefer the existing shared partials and helper methods before adding new template structures.

Common entry points:

- `app/views/shared/`
- `app/views/measures/`
- `app/views/commodities/`
- `app/views/headings/`
- `app/views/search/`
- `app/views/green_lanes/`
- `app/views/rules_of_origin/`
- `app/views/myott/`

## Assets

`app/assets/stylesheets/application.sass.scss` imports GOV.UK Frontend, selected GOV.UK Publishing Components styles, and service-specific Sass modules under `app/assets/stylesheets/src/`.

Use GOV.UK Sass mixins, spacing, typography, colours, and component classes before introducing custom CSS. Keep custom Sass scoped to a named component or journey.

JavaScript is loaded from `app/javascript/application.js` through importmap. Use existing Stimulus/controller patterns for interactive behaviour and keep non-essential behaviour progressive-enhancement friendly.
