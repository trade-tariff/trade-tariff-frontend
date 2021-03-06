ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'

SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# require models
Dir[Rails.root.join("app/models/*.rb")].each { |f| require f }

require 'capybara/rails'
require 'capybara/rspec'

Capybara.register_driver(:selenium_chrome_headless) do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')

  Capybara::Selenium::Driver.new(
    app,browser: :chrome, options: options
  )
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

  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL

  config.before do
    allow(TariffUpdate).to receive(:all).and_return([OpenStruct.new(updated_at: Date.today)])
  end

  config.after(:each, type: :feature, js: true) do
    errors = page.driver.browser.manage.logs.get(:browser)
    if errors.present?
      aggregate_failures 'javascript errrors' do
        errors.each do |error|
          puts error.level
          expect(error.level).not_to eq('SEVERE'), error.message
          next unless error.level == 'WARNING'
          STDERR.puts 'WARN: javascript warning'
          STDERR.puts error.message
        end
      end
    end
  end
end
