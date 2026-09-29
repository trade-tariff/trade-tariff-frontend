# Trade Tariff Frontend

Trade Tariff Frontend is the public
[Online Trade Tariff website](https://www.gov.uk/trade-tariff).
It helps people find commodity codes, duties, VAT, quotas and measures for goods
moving to and from the UK, including Northern Ireland.

This Ruby on Rails application renders the website and the duty calculator.
It gets tariff data from
[Trade Tariff Backend](https://github.com/trade-tariff/trade-tariff-backend);
it does not maintain a local tariff database.
[Trade Tariff Admin](https://github.com/trade-tariff/trade-tariff-admin) is the
separate staff interface for managing content and operations.

## Run locally

### Prerequisites

- Ruby at the version in [.ruby-version](.ruby-version) and Bundler.
- Node.js and Yarn for stylesheets and JavaScript tooling.
- A local Trade Tariff Backend with data for the journeys you need.
- Chrome or Chrome for Testing for browser-based RSpec tests.

Clone this repository, or follow the [fork workflow](CONTRIBUTING.md#fork-and-branch)
if you want to contribute without write access.

### Configure the application

[.env.development](.env.development) contains development defaults. Put local
overrides in `.env.development.local`. Do not commit secrets or point local
write operations at production services.

`API_SERVICE_BACKEND_URL_OPTIONS` maps `uk` and `xi` to their API roots, including
`/api`. For example, a UK backend on port 3000 uses
`http://localhost:3000/uk/api`. Northern Ireland uses the `xi` service and needs
its own backend process and data. Set its URL to the port where that process runs.

The API client requests version 2. Authentication and other integrations need
additional configuration for those journeys; the basic tariff pages do not
require a local Identity service.

### Set up and start

```sh
yarn install --frozen-lockfile
bin/setup --skip-server
bin/dev
```

`bin/setup` installs Ruby dependencies and clears temporary files. Without
`--skip-server`, it also starts the application. `bin/dev` starts Rails on port
3001 and watches the CSS build. Open <http://localhost:3001>.

## Run checks

Compile the stylesheets and assets before running tests that render pages:

```sh
yarn build:css
RAILS_ENV=test bin/rails assets:precompile
bundle exec rspec
yarn jest
bundle exec rubocop
bundle exec brakeman
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for hooks, accessibility checks and pull
requests. [GitHub Actions](.github/workflows/ci.yml) defines the CI checks.

## Find your way around

- [Documentation index](docs/README.md): architecture and domain guides.
- [Architecture](docs/architecture/README.md): routing, API clients and rendering.
- [Duty calculator](docs/architecture/duty-calculator.md): the calculation journey.
- [Style guide](docs/style-guide.md): Ruby, Rails, GOV.UK components and tests.
- [Development and delivery](docs/development-and-delivery.md): maintainer conventions.

## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) for reporting bugs, making a fork,
submitting changes and reporting security issues privately.

## Licence

The code and associated documentation are available under the
[MIT licence](LICENCE.md), with the existing Crown copyright notice.
Keep the licence and copyright notice when you reuse the software.
Third-party dependencies and assets retain their own licences. In particular,
check the [GOV.UK Frontend licence](https://github.com/alphagov/govuk-frontend/blob/main/LICENSE.txt)
before reusing GOV.UK fonts or branding in another service.
