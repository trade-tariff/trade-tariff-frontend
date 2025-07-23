# Trade Tariff Frontend

<https://www.trade-tariff.service.gov.uk/find_commodity>

This is the front-end application for [Trade Tariff Backend][backend],
which provides the Backend APIs.

> Make sure you install and enable all pre-commit hooks https://pre-commit.com/

## Configuration

You can run the front-end on your local machine without changing the file `.env.development`,
which contains all the environment variables used in development.

Here are some of the relevant Env variables:

- `API_SERVICE_BACKEND_URL_OPTIONS`: to set the BE address for he UK and XI (EU)
    For example: `API_SERVICE_BACKEND_URL_OPTIONS={"uk":"http://localhost:3001","xi":"http://localhost:3002"}`

- `TARIFF_API_VERSION`:  to set the APIs version, the current ver. is __2__.

## Running the frontend

Requires:

- Ruby
- Rails
- node
- yarn
- Chrome or Chrome-for-testing for browser based testing

Uses:

- Redis (production only)

Commands:

```sh
bin/setup
bin/rails start
```

## Running the test suite

To run the spec use the following command:

```sh
bundle exec rspec
```

Note that lots of tests will fail without the assets being compiled. In order to run the tests you need to run `bin/rails assets:precompile` first.

### Guard

We use [Guard](https://github.com/guard/guard) to run the test suite automatically when files are changed.

To run Guard use the following command:

```sh
bundle exec guard
```

This will run the appropriate test suite for the file you are working on.

## Troubleshooting

Sometimes, when trying to load the front page, you get the error:
__[Webpacker] Compilation failed__

Try to clear Yarn and Webpacker Cache:

```sh
yarn cache clean
bin/rails setup
```

### Disabling Continuous Deployments

We continuously deploy our frontend application to production after a staging deployment passes some end-to-end tests.

You can disable this by:

- Navigating to the [production environment deployment rule][production] page
- Updating the `Required Reviewers` section to the reviewers you want to control production deployments
- Hit the `Save protection rules` button

[backend]: https://github.com/trade-tariff/trade-tariff-backend
[production]: https://github.com/trade-tariff/trade-tariff-frontend/settings/environments/6229078129/edit
