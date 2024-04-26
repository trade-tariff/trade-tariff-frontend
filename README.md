# Trade Tariff Frontend

<https://www.trade-tariff.service.gov.uk/trade-tariff/sections>

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

## Troubleshooting

Sometimes, when trying to load the front page, you get the error:
**[Webpacker] Compilation failed**

Try to clear Yarn and Webpacker Cache:

```sh
yarn cache clean
bin/rails setup
```

[backend]: https://github.com/trade-tariff/trade-tariff-backend
