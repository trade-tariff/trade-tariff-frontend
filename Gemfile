source 'https://rubygems.org'

ruby file: '.ruby-version'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 8.0'

gem 'csv'
gem 'faraday'
gem 'faraday-http-cache'
gem 'faraday-net_http_persistent'
gem 'faraday-retry'
gem 'inline_svg'
gem 'jwt'
gem 'kaminari'
gem 'multi_json'
gem 'net-http-persistent'
gem 'newrelic_rpm'
gem 'roo'
gem 'routing-filter', github: 'trade-tariff/routing-filter'
gem 'uktt', git: 'https://github.com/trade-tariff/uktt.git'

# Assets
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'importmap-rails'
gem 'propshaft'
gem 'stimulus-rails'
gem 'turbo-rails'

# gov UK
gem 'govspeak'
gem 'govuk_design_system_formbuilder'
gem 'nokogiri'
gem 'plek'
gem 'wizard_steps'

# Logging
gem 'lograge'
gem 'logstash-event'

# Web Server
gem 'puma'
gem 'rack-cors'

# Redis
gem 'redis'

# AWS
gem 'aws-actionmailer-ses'
gem 'aws-sdk-rails'

group :development do
  gem 'letter_opener'
  gem 'rubocop-capybara'
  gem 'rubocop-govuk'
  gem 'ruby-lsp-rails'
  gem 'ruby-lsp-rspec'
end

group :development, :test do
  gem 'amazing_print'
  gem 'dotenv-rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
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
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

group :production do
  gem 'rack-attack'
  gem 'rack-timeout'
end
