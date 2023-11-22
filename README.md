# Trade Tariff Frontend

__Now maintained at https://github.com/trade-tariff/trade-tariff-frontend__

https://www.trade-tariff.service.gov.uk/trade-tariff/sections

This is the front-end application for [Trade Tariff Backend](https://github.com/trade-tariff/trade-tariff-backend), which provides the Backend APIs.


## Configuration

You can run the front-end on your local machine without changing the file `.env.development`, which contains all the environment variables used in development.

Here are some of the relevant Env variables:

- `API_SERVICE_BACKEND_URL_OPTIONS`: to set the BE address for he UK and XI (EU) services.
    For example: `API_SERVICE_BACKEND_URL_OPTIONS={"uk":"http://localhost:3001","xi":"http://localhost:3002"}`

- `TARIFF_API_VERSION`:  to set the APIs version, the current ver. is **2**.

## Running the frontend

Requires:
* Ruby
* Rails
* node
* yarn
* Chrome or Chrome-for-testing for browser based testing

Uses:
* Redis (production only)

Commands:

```
  $ bin/setup
  $ bin/rails start
```

## Running the test suite

To run the spec use the following command:

```
  $ bundle exec rspec
```

## Scaling the application

We are using CF [AutoScaler](https://github.com/cloudfoundry/app-autoscaler) plugin to perform application autoscaling. Set up guide and documentation are available by links below:

https://docs.cloud.service.gov.uk/managing_apps.html#autoscaling

https://github.com/cloudfoundry/app-autoscaler/blob/develop/docs/Readme.md



To check autoscaling history run:

    cf autoscaling-history APPNAME

To check autoscaling metrics run:

    cf autoscaling-metrics APP_NAME METRIC_NAME
 
To remove autoscaling policy and disable App Autoscaler run:

    cf detach-autoscaling-policy APP_NAME

To create or update autoscaling policy for your application run:

    cf attach-autoscaling-policy APP_NAME ./policy.json


Current autosscaling policy files are [here](https://github.com/trade-tariff/trade-tariff-frontend/tree/main/config/autoscaling).

## Troubleshooting

Sometimes, when trying to load the front page, you get the error: **[Webpacker] Compilation failed**

Try to clear Yarn and Webpacker Cache:
```
  $ yarn cache clean
  $ bin/rails setup
```
some change
