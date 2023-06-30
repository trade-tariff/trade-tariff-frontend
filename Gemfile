source 'https://rubygems.org'

ruby File.read('.ruby-version')

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.0'

gem 'addressable'
gem 'faraday', '~> 2'
gem 'faraday-http-cache'
gem 'faraday-net_http_persistent'
gem 'faraday-retry'
gem 'multi_json'
gem 'net-http-persistent'
gem 'routing-filter', github: 'svenfuchs/routing-filter'
gem 'yajl-ruby'

# Assets
gem 'bootsnap', require: false
gem 'kaminari'
gem 'responders'
gem 'webpacker'

# gov UK
gem 'govspeak'
gem 'nokogiri', '~> 1.14.3' # https://github.com/sparklemotion/nokogiri/issues/2205
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

# Newrelic
gem 'newrelic_rpm'

# For MeursingLookup functionality
gem 'govuk_design_system_formbuilder'
gem 'wizard_steps'

# Sentry
gem 'sentry-rails'

group :development do
  gem 'letter_opener'
  gem 'rubocop-govuk'
  gem 'web-console'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'forgery'
  gem 'rack-test'
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing', branch: 'master'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end
