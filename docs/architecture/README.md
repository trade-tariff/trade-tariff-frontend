# Architecture

These pages give a code-level map of the Trade Tariff Frontend. They describe stable boundaries rather than every controller, model, or template.

## Pages

- [System overview](system-overview.md)
- [Request routing](request-routing.md)
- [Backend API client](backend-api-client.md)
- [Frontend rendering](frontend-rendering.md)

## Source Anchors

Start from these files when verifying architecture claims:

- `Gemfile`
- `package.json`
- `config/routes.rb`
- `config/routes/duty_calculator.rb`
- `config/initializers/backend.rb`
- `app/services/client_builder.rb`
- `lib/api_entity.rb`
- `lib/trade_tariff_frontend.rb`
- `lib/trade_tariff_frontend/service_chooser.rb`
- `lib/routing_filter/service_path_prefix_handler.rb`
- `app/views/layouts/application.html.erb`
- `app/assets/stylesheets/application.sass.scss`
- `app/javascript/application.js`

## Internal Context

The frontend depends on Trade Tariff Backend for tariff data and on wider OTT platform conventions for delivery. Treat this repository, CI configuration, and the backend API contract as authoritative where external notes disagree.
