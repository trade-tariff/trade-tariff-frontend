ENV['RAILS_ENV'] ||= 'test'

ENV['ENQUIRY_FORM_ENABLED'] = 'true'

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

Capybara.default_max_wait_time = 5

require 'capybara/cuprite'
Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  opts = {
    browser_name: :chrome,
    window_size: [1200, 800],
    process_timeout: 30,
    timeout: 30,
  }

  if File.exist?('/.dockerenv') || # check for docker
      File.exist?('/run/.containerenv') # check for podman + other oci runtimes
    opts[:browser_options] = { 'no-sandbox': nil }
  end

  Capybara::Cuprite::Driver.new(app, **opts)
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true # add this line
end

VCR.use_cassette('geographical_areas#1013') do
  GeographicalArea.european_union
end

Capybara.javascript_driver = :cuprite

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
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.file_fixture_path = 'spec/fixtures'
  config.expose_dsl_globally = false

  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers
  config.include Rails.application.routes.url_helpers, :step
  config.include Capybara::DSL
  config.include ApiResponsesHelper
  config.include Shoulda::Matchers::ActiveModel
  config.include ActiveSupport::Testing::TimeHelpers

  config.include_context 'with switch service banner', type: :view

  config.before do
    allow(TariffUpdate).to receive(:all).and_return([OpenStruct.new(applied_at: Time.zone.today)])
    allow(News::Item).to receive(:latest_banner).and_return build(:news_item, :banner)
    Thread.current[:service_choice] = nil

    Thread.current[:commodity_context_service] = DutyCalculator::CommodityContextService.new

    Rails.application.config.duty_calculator_http_client_uk = FakeUkttHttp.new(nil, 'uk', nil, nil)
    Rails.application.config.duty_calculator_http_client_xi = FakeUkttHttp.new(nil, 'xi', nil, nil)

    stub_const('Uktt::Http', FakeUkttHttp)
  end

  config.after(:each, type: :feature, js: true) do
    Thread.current[:service_choice] = nil
  end

  config.before :each, :user_session do
    allow(DutyCalculator::UserSession).to receive_messages(build: user_session, build_from_params: user_session, get: user_session)
  end
end
