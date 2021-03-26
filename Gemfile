source 'https://rubygems.org'
ruby '~> 2.7'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Exclude mimemagic dependency and fetch only what we need
gem 'actionmailer', '~> 6.0'
gem 'actionpack', '~> 6.0'
gem 'actionview', '~> 6.0'
gem 'activemodel', '~> 6.0'
gem 'activerecord', '~> 6.0'
gem 'activesupport', '~> 6.0'
gem 'railties', '~> 6.0'

gem 'addressable', '~> 2.3'
gem 'faraday'
gem 'faraday_middleware', '~> 1'
gem 'hashie', '~> 3.4'
gem 'multi_json', '~> 1.11'
gem 'routing-filter', '~> 0.6.3'
gem 'yajl-ruby', '~> 1.3.1', require: 'yajl'

# Assets
gem 'bootsnap', require: false
gem 'kaminari', '~> 1.0'
gem 'responders', '~> 3.0.0'
gem 'webpacker', '~> 5.2'

# gov UK
gem 'govspeak', '~> 6.5.6'
gem 'plek', '~> 1.11'

gem 'connection_pool', '~> 2.2'

gem 'nokogiri', '>= 1.10.10'

# Logging
gem 'lograge'
gem 'logstash-event'

# Web Server
gem 'puma', '~> 5.0.4'
gem 'rack-attack'
gem 'rack-cors'

# Redis
gem 'redis-rails'

# AWS
gem 'aws-sdk-rails', '~> 3'

group :development do
  gem 'letter_opener'
  gem 'rubocop-govuk'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :test do
  gem 'capybara', '~> 3'
  gem 'factory_bot_rails'
  gem 'forgery'
  gem 'rack-test'
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing', branch: 'master'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 4'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4'
  gem 'simplecov', '~> 0.18', require: false
  gem 'timecop', '~> 0.9.1'
  gem 'vcr', '~> 3.0.3'
  gem 'webdrivers', '~> 4.4'
  gem 'webmock', '~> 3.8.0'
end

group :production do
  gem 'sentry-raven'
end
