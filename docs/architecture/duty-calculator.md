# Duty Calculator

This page maps the duty calculator architecture. It folds in the useful structure from the local `duty_calculator_architecture.pdf` guide and verifies it against the current source.

The calculator does not own tariff data. It orchestrates a legal and product decision journey around backend measures:

1. identify the trade route and service context
2. collect the facts needed for that route
3. select the UK, XI, or comparison model
4. build duty options from applicable measures
5. evaluate formula components
6. explain the result to the user

## Entry Points

- Routes: `config/routes/duty_calculator.rb`
- Step controllers: `app/controllers/duty_calculator/steps/`
- Step models: `app/models/duty_calculator/steps/`
- Session state: `app/models/duty_calculator/user_session.rb`
- API-backed entities: `app/models/duty_calculator/api/`
- Option construction: `app/models/duty_calculator/duty_calculator.rb`, `app/services/duty_calculator/duty_options/`
- ROW to NI comparison: `app/models/duty_calculator/row_to_ni_duty_calculator.rb`, `app/services/duty_calculator/duty_options/chooser.rb`
- Formula evaluation: `app/services/duty_calculator/expression_evaluators/`
- Result views: `app/views/duty_calculator/steps/duty/`
- Link from commodity pages: `app/views/measures/grouped/_tariff_duty_calculator_link.html.erb`

## Journey Shape

The route file defines a step-by-step journey:

- import date
- import destination
- country of origin
- customs value
- trader scheme
- final use
- certificate of origin
- annual turnover
- planned processing
- measure amount
- VAT
- confirmation
- interstitial
- duty result
- additional codes, Meursing additional codes, excise, and document codes when required

Each step has a controller and usually a model under `DutyCalculator::Steps`. `DutyCalculator::Steps::Base` provides common step behaviour, session cleanup, and previous/next path expectations. `DutyCalculator::Steps::BaseController` handles session integrity, commodity context, GOV.UK form builder setup, commodity not-found redirects, and common helpers.

## Session and Route Decisions

`DutyCalculator::UserSession` stores journey answers in `session['answers']` and exposes route predicates such as:

- `ni_to_gb_route?`
- `gb_to_ni_route?`
- `eu_to_ni_route?`
- `row_to_gb_route?`
- `row_to_ni_route?`
- `deltas_applicable?`
- `meursing_route?`

This is the main place to check before changing question order, route branching, or whether UK/XI data is used. `deltas_applicable?` is especially sensitive because it controls whether ROW to NI logic compares UK and XI duty outcomes.

## Option Construction

`DutyCalculator::DutyCalculator` builds an `OptionCollection` from applicable backend measures. It starts from default options, maps each applicable measure type to a duty option class, merges additional duty rows, and includes the relevant VAT measure.

Duty option classes live under `app/services/duty_calculator/duty_options/` and cover categories such as:

- third-country tariff
- tariff preference
- quota
- suspension
- waiver
- anti-dumping, countervailing, safeguard, excise, and other additional duties

Preferences, quotas, and suspensions are usually alternative options. Remedies, VAT, excise, and some additional duties can be additive rows on top of the selected base duty option.

## Formula Evaluation

Expression evaluators under `app/services/duty_calculator/expression_evaluators/` convert measure components and trader inputs into calculated rows. They cover ad valorem percentages, measurement units, compound expressions, retail price, alcohol volume, sucrose, SPQ, and VAT.

Compound expressions are high risk. `ExpressionEvaluators::Compound` evaluates component operators and conjunction operators. The current code treats tariff `MAX` and `MIN` operators according to the domain semantics used by the backend data, not plain English wording.

## ROW to NI Comparison

ROW to NI can compare UK and XI outcomes. `DutyCalculator::RowToNiDutyCalculator` builds comparable options from UK and XI option collections, then `DutyOptions::Chooser` selects the UK option when the absolute delta is within 3% of customs value; otherwise it selects the XI option.

When changing this area, test:

- UK-only option categories
- XI-only option categories
- duplicate third-country tariff options
- footnote suffixes explaining why an option was selected
- customs value inputs used by the 3% comparison

## Testing

Duty calculator coverage is spread across:

- `spec/controllers/duty_calculator/steps/`
- `spec/models/duty_calculator/`
- `spec/services/duty_calculator/`
- `spec/helpers/duty_calculator/`
- `spec/decorators/duty_calculator/`
- `spec/fixtures/duty_calculator/`
- `spec/support/shared_examples/a_duty_calculator.rb`

For PRs, include the smallest relevant unit specs plus a journey-level or controller spec when route branching, step order, session state, or rendered explanations change.

## Review Risk

Treat duty calculator changes as high risk when they affect:

- route branching or session predicates
- measure filtering or applicable option selection
- additional codes, document codes, certificates, quotas, Meursing, VAT, excise, or remedies
- formula component evaluation
- UK/XI comparison and 3% delta logic
- copy explaining why a trader has no duty, a waiver, or a selected option

Manual PR evidence should include the route exercised, commodity code, origin, destination, import date, key answers, and the visible result or explanation.
