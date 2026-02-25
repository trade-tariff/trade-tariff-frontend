ARG RUBY_VERSION=4.0.1
ARG ALPINE_VERSION=3.23

#### Build image #####

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS builder

WORKDIR /build

RUN apk add --no-cache build-base git yarn tzdata yaml-dev openssl-dev && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

COPY .ruby-version Gemfile Gemfile.lock .
RUN bundle config set without 'development test' && \
    bundle install --jobs=4 --retry=3

COPY package.json yarn.lock .

RUN yarn install --frozen-lockfile

COPY . .

ENV CORS_HOST="localhost" \
    GOVUK_APP_DOMAIN="localhost" \
    GOVUK_WEBSITE_ROOT="http://localhost/" \
    RAILS_ENV=production \
    NODE_OPTIONS="--openssl-legacy-provider"

RUN bundle exec rails assets:precompile

RUN rm -rf node_modules log tmp /usr/local/bundle/cache /yarn/cache .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete && \
    rm -rf vendor/bundle/ruby/*/cache/*

#### End build image #####

#### Production image #####

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS production

RUN apk add --no-cache \
    tzdata \
    openssl-dev && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

ENV RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production \
    PORT=8080 \
    TZ=Europe/London

RUN addgroup -S tariff && \
    adduser -S tariff -G tariff

WORKDIR /home/tariff

USER tariff

COPY --chown=tariff:tariff --from=builder /build .
COPY --chown=tariff:tariff --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 8080

HEALTHCHECK CMD nc -z 0.0.0.0 $PORT

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
#CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

#### End production image #####
