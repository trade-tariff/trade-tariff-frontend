# Guided VAT determination prototype

This prototype tests whether maintained decision rules can guide a user from the VAT options already returned by tariff data to one supported option.

Its content is illustrative and must not be used for a VAT declaration. The standalone comparison page is available only in development and test. The production-shaped journey is integrated with the duty calculator behind the `vat_guidance` Flagsmith feature flag, which defaults off in production.

## Run it

Start the frontend, then open:

```text
/vat-guidance-prototype
```

To exercise the integrated route, use search or browse to select one of the fixture commodities, start the tariff duty calculator, and continue until the VAT step. Select **Get help choosing a VAT rate**.

The examples use four commodities represented in tariff fixture data:

- cherry tomatoes (`0702000007`), testing food, catering and mixed-supply conditions
- breeding sows weighing at least 160 kg (`0103921100`), testing the food-producing animal condition
- fresh plums (`0809400500`), testing a second food journey with the same tariff options
- a specified vegetable oil blend from Canada (`1516209821`), testing animal-feed and fuel use, including an intentional “not determined” branch

## Architecture under test

- `config/vat_guidance_prototype/rules.yml` separates reusable rule sets from commodity applicability mappings.
- Rule sets contain effective dates, jurisdictions, approved outcomes, question graphs and source metadata.
- Applicability mappings associate one rule set with one or more commodity codes and provide product-specific wording.
- `VatGuidancePrototype::RuleRepository` compiles one immutable runtime repository, interpolates product wording and validates graphs, outcomes, effective dates and unique commodity mappings at load time.
- `VatGuidancePrototype::CoverageAssessment` treats every commodity with more than one live VAT option as eligible.
- `VatGuidancePrototype::GenericJourneyFactory` builds a confirmation journey from the current backend VAT options when no reviewed product mapping exists.
- `VatGuidancePrototype::DecisionEngine` executes the graph deterministically.
- The duty-calculator controller stores only the commodity code and guidance answers in the session.
- A determined outcome can be applied only when its key is present in the current filtered `applicable_vat_options` from Trade Tariff Backend.

The standalone page uses a labelled option catalogue for demonstration. The integrated journey passes the live commodity, date, destination and earlier duty-calculator filtering context into the assessment and engine. VAT rates and labels are therefore not maintained as production rule content.

## Coverage model

Eligibility must be calculated from the live, filtered backend response rather than a stored count or a static commodity list. The prototype has two exhaustive states:

1. **Not eligible** — zero or one VAT option remains, so the existing calculator flow continues.
2. **Guided** — more than one VAT option remains, so the user enters either a reviewed product journey or the generic confirmation journey.

Reviewed journeys ask factual questions derived from product-specific HMRC guidance. The generic journey is deliberately narrower: it first requires the user to confirm that they established the treatment from current HMRC guidance or professional advice, then lets them record only one of the live tariff options. If they have not confirmed a treatment, it returns “not determined”.

This gives every multi-option commodity a working, traceable path without pretending that a generic question graph can replace product-specific VAT rules. Reviewed coverage can grow independently by adding effective-dated mappings to `rules.yml`. Tomatoes and plums demonstrate two mappings sharing one `unprocessed_food` graph.

## Search and discovery integration

The prototype does not introduce a second product search. Users retain the current journey:

1. search, guided search, browse or A–Z to find the commodity
2. open the commodity page and start the tariff duty calculator
3. answer the existing trade-context questions
4. receive guided help only when the filtered VAT step contains multiple options
5. apply a supported result to the existing **Check your answers** page, or return to the unchanged VAT radio options

This places guidance after commodity discovery and after additional-code and trade filters, where `applicable_vat_options` is most accurate.

The food scenarios are based on [Food products (VAT Notice 701/14)](https://www.gov.uk/guidance/food-products-and-vat-notice-70114), the sow and animal-feed branches on [Animals and animal food (VAT Notice 701/15)](https://www.gov.uk/guidance/animals-and-animal-food-notice-70115), and the fuel branches on [Fuel and power (VAT Notice 701/19)](https://www.gov.uk/guidance/vat-on-fuel-and-power-notice-70119). All examples also link to HMRC’s [import VAT guidance](https://www.gov.uk/guidance/vat-imports-acquisitions-and-purchases-from-abroad).

Each journey first confirms the exact tariff description. It then asks only the factual questions needed by the cited HMRC guidance, chooses only from VAT options present for that commodity, and abstains when those sources or options do not support a safe result.

## Evaluation exercises

1. Have a VAT subject-matter expert compare every question, branch and outcome with the cited source.
2. Change a source condition, update the affected YAML rule and inspect whether the diff is understandable.
3. Add an unsupported outcome key and confirm repository validation rejects it.
4. Remove an option from the map passed to the engine and confirm it returns “not determined”.
5. Use an unmapped multi-option commodity and confirm the generic journey contains exactly the options returned by the backend.
6. Decline independent confirmation in the generic journey and confirm that it does not select a rate.
7. Give the same answer sets repeatedly and confirm the outcomes are identical.
8. Ask a content designer and representative users to review whether the questions can be answered reliably.

## Deliberately missing

- AI-generated rules
- legal/content approval workflow
- change monitoring for GOV.UK guidance
- analytics and user research instrumentation
- an editorial store or publishing interface independent of application deployment
- complete product-specific HMRC-reviewed rule-set coverage

Those should be considered only after the deterministic content model and ownership process have been shown to be viable.
