source 'https://rubygems.org'

ruby File.read('.ruby-version')

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6'

gem 'addressable'
gem 'faraday', '= 1.3.0' # TODO: Debug issue with newer versions of Faraday client under high loads
gem 'faraday_middleware'
gem 'multi_json'
gem 'routing-filter', github: 'svenfuchs/routing-filter'
gem 'yajl-ruby'

# Assets
gem 'bootsnap', require: false
gem 'kaminari'
gem 'responders'
gem 'webpacker'

# gov UK
gem 'govspeak'
gem 'nokogiri', '~> 1.12.4' # https://github.com/sparklemotion/nokogiri/issues/2205
gem 'plek'

gem 'connection_pool'

# Logging
gem 'lograge'
gem 'logstash-event'

# Web Server
gem 'puma'
gem 'rack-cors'

# Redis
gem 'redis-rails'

# AWS
gem 'aws-sdk-rails'

# Newrelic
gem 'newrelic_rpm'

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
  gem 'timecop'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end

group :production do
  gem 'sentry-raven'
end
