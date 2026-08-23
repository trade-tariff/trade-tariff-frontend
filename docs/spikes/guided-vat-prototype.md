# AI-1146 guided VAT duty-calculator integration

The duty calculator's existing VAT step demonstrates the AI-1146 backend artifact end to end. For a supported commodity, it loads the hash-validated, precomposed commodity route from `GET /uk/api/v2/vat_guidance_demo` and offers guided VAT questions alongside the existing VAT-rate choices.

The demo uses synthetic review decisions. It is not an HMRC determination, is not approved for runtime or production use, and must not be used to make a VAT declaration.

## Run locally

Start Trade Tariff Backend on port 3000:

```sh
cd ../trade-tariff-backend
RAILS_ENV=development bundle exec rails server -p 3000
```

Start Trade Tariff Frontend on port 3001:

```sh
cd ../trade-tariff-frontend
RAILS_ENV=development asdf exec bundle exec rails server -p 3001
```

Open a supported commodity's duty calculation and continue to its VAT step, for example:

```text
http://localhost:3001/duty-calculator/2005202000/import-date
```

The frontend development configuration points its UK API client at `http://localhost:3000/uk/api`. If the validation login is enabled, use the locally configured `BASIC_PASSWORD`.

The endpoint and nested duty-calculator routes are enabled automatically in development and test. For a deployed demo, set `VAT_GUIDANCE_DEMO_ENABLED=true` on both applications and configure the frontend UK API host to the corresponding backend deployment.

## Demo flow

1. The frontend requests the AI-1146 projection from Trade Tariff Backend.
2. The backend verifies the committed artifact hash and rejects any artifact that is runtime-approved, production-ready, not simulation-ready or contains a production-eligible journey.
3. The frontend independently validates the safety flags and looks up the current duty-calculator commodity among the 11 composed commodity journeys.
4. When guidance exists, the VAT step offers the commodity-composed journey and any backend-associated notice journeys. The user chooses the relevant guidance and answers GOV.UK radio-button questions without leaving the duty calculation.
5. `ComposedRouteEngine` filters the 72 backend-generated routes by the answer prefix and requires one unambiguous next question or terminal route.
6. The result displays the candidate treatment, answer trail and source evidence, then returns to the VAT step with the matching VAT option selected for explicit confirmation.

The frontend does not maintain or infer a second VAT ruleset. It cannot select an answer, question or result absent from the backend artifact.

The standalone `/vat-guidance-prototype` chooser is not routed. For the curated Chapter 20 commodities, the VAT step offers both the commodity-composed route and the associated evidence-only VAT Notice 701/14 and 709/1 journeys. Protective-equipment and Chapter 84 commodities receive their own composed journey only.

## Safety boundary

- `end_to_end_simulation_ready` must be `true`.
- `runtime_approved` and `production_ready` must remain `false`.
- Every composed journey must remain `production_eligible: false`.
- Missing, malformed, unsupported or unsafe backend responses leave the existing VAT-rate form usable without guided controls.
- Results are labelled as candidates produced with synthetic review decisions.
- The guidance result does not bypass the existing VAT form: the user returns to the VAT step and explicitly submits the selected option before it affects the calculation.

## Verification

Run the frontend contract and browser-journey specs:

```sh
asdf exec bundle exec rspec \
  spec/services/vat_guidance_prototype/composed_journey_repository_spec.rb \
  spec/services/vat_guidance_prototype/composed_route_engine_spec.rb \
  spec/requests/duty_calculator/steps/vat_guidance_controller_spec.rb \
  spec/features/vat_guidance_demo_spec.rb
```

The backend request and artifact specs live in the AI-1146 backend branch. For a manual demonstration, begin a duty calculation for a supported commodity, exercise at least one standard route and one VATZ or VATR route, return to the VAT step, and confirm that the suggested option is selected but is not saved until the user submits the VAT form.
