# Backend API Client

The frontend consumes Trade Tariff Backend APIs rather than storing most tariff data locally.

## Client Setup

`config/initializers/backend.rb` creates UK and XI clients with `ClientBuilder`. The builder configures Faraday with:

- JSON API accept header
- retry behaviour for safe requests
- HTTP caching through Rails cache when available
- persistent Net::HTTP adapter
- JSON response parsing
- user agent containing the frontend revision

Key files:

- `config/initializers/backend.rb`
- `app/services/client_builder.rb`
- `lib/trade_tariff_frontend/service_chooser.rb`

## API Entities

`lib/api_entity.rb` gives API-backed models ActiveModel-style behaviour and common request helpers. Models under `app/models/` use those helpers to call backend endpoints, parse JSON:API responses, expose relationships, and hydrate validation errors from backend responses.

When changing API-backed behaviour:

- Check the backend endpoint contract and fixtures.
- Update or add VCR fixtures where specs make HTTP-like backend calls.
- Keep error handling visible to users through GOV.UK error summaries, field errors, or service error pages as appropriate.
- Treat 404, 403, 401, timeout, and invalid JSON cases as behaviour that may need tests.

## Source Anchors

- `lib/api_entity.rb`
- `lib/tariff_jsonapi_parser.rb`
- `app/models/commodity.rb`
- `app/models/measure.rb`
- `app/models/search.rb`
- `app/services/client_builder.rb`
- `spec/support/vcr.rb`
- `spec/support/api_responses_helper.rb`
