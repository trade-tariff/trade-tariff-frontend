# Trade Tariff Frontend

__Now maintained at https://github.com/trade-tariff/trade-tariff-frontend__

https://www.trade-tariff.service.gov.uk/trade-tariff/sections

This is the front-end application for:

* [Trade Tariff Backend](https://github.com/trade-tariff/trade-tariff-backend)

This application requires one or more Trade Tariff Backend APIs to be running and the following env variables set: `API_SERVICE_BACKEND_DEFAULT`, `API_SERVICE_BACKEND_URL_OPTIONS`.

For example:

```
API_SERVICE_BACKEND_DEFAULT=uk
API_SERVICE_BACKEND_URL_OPTIONS={"uk":"http://localhost:3001","xi":"http://localhost:3002"}
```

By default (without a service choice prefix) the application will route to whatever the `API_SERVICE_BACKEND_DEFAULT` specifies from the `API_SERVICE_BACKEND_URL_OPTIONS` list.

To use latest api version need to set up env variable `TARIFF_API_VERSION`. 

## Running the frontend

Requires:
* Ruby
* Rails
* node & npm
* yarn

Uses:
* Redis

Commands:

    ./bin/setup
    yarn install
    foreman start

## Running the test suite

To run the spec use the following command:

    RAILS_ENV=test bundle exec rake

## Deploying the application

We deploy to cloud foundry, so you need to have the CLI installed, and the following [cf plugin](https://github.com/bluemixgaragelondon/cf-blue-green-deploy) installed:


Set the following ENV variables:
* CF_USER
* CF_PASSWORD
* CF_ORG
* CF_SPACE
* CF_APP
* SLACK_CHANNEL
* SLACK_WEBHOOK

Then run

    ./bin/deploy


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












