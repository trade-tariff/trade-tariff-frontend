ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'

SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'active_record'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# require models
Dir[Rails.root.join('app/models/*.rb')].sort.each { |f| require f }

require 'capybara/rails'
require 'capybara/rspec'

Capybara.register_driver(:selenium_chrome_headless) do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')

  Capybara::Selenium::Driver.new(
    app, browser: :chrome, options:
  )
end

VCR.use_cassette('geographical_areas#1013') do
  GeographicalArea.european_union
end

Capybara.javascript_driver = :selenium_chrome_headless

Capybara.ignore_hidden_elements = false

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.order = :random
  config.infer_base_class_for_anonymous_controllers = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.file_fixture_path = 'spec/fixtures'
  config.expose_dsl_globally = false

  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL
  config.include ApiResponsesHelper
  config.include Shoulda::Matchers::ActiveModel

  config.include_context 'with switch service banner', type: :view

  config.before do
    allow(TariffUpdate).to receive(:all).and_return([OpenStruct.new(applied_at: Time.zone.today)])
    allow(News::Item).to receive(:latest_banner).and_return build(:news_item, :banner)
    Thread.current[:service_choice] = nil
  end

  config.after(:each, type: :feature, js: true) do
    Thread.current[:service_choice] = nil
  end
end

