source 'https://rubygems.org'

ruby file: '.ruby-version'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 8.0'

gem 'addressable'
gem 'faraday', '~> 2'
gem 'faraday-http-cache'
gem 'faraday-net_http_persistent'
gem 'faraday-retry'
gem 'multi_json'
gem 'net-http-persistent'
gem 'newrelic_rpm'
gem 'routing-filter', github: 'trade-tariff/routing-filter'
gem 'yajl-ruby'

# Assets
gem 'bootsnap', require: false
gem 'kaminari'
gem 'webpacker'

# gov UK
gem 'govspeak'
gem 'nokogiri'
gem 'plek'

gem 'connection_pool'

# Logging
gem 'lograge'
gem 'logstash-event'

# Web Server
gem 'puma'
gem 'rack-cors'

# Redis
gem 'redis'

# AWS
gem 'aws-sdk-rails'

# For MeursingLookup functionality
gem 'govuk_design_system_formbuilder'
gem 'wizard_steps'

# Sentry
gem 'sentry-rails'

group :development do
  gem 'letter_opener'
  gem 'rubocop-govuk'
  gem 'solargraph'
  gem 'web-console'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'guard-rspec', '~> 4.7'
  gem 'guard-rubocop'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'cuprite'
  gem 'factory_bot_rails'
  gem 'forgery'
  gem 'rack-test'
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing', branch: 'master'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end
