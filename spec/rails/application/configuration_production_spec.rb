require 'spec_helper'

RSpec.describe Rails::Application::Configuration do
  let(:production_config) { described_class.new(Rails.root) }

  before do
    production_config.lograge = ActiveSupport::OrderedOptions.new
    allow(Rails.application).to receive(:config).and_return(production_config)
    allow(Rails.application).to receive(:configure) { |&block| Rails.application.instance_eval(&block) }
    load Rails.root.join('config/environments/production.rb')
  end

  it 'logs the trusted experiment label rather than request parameters' do
    event = instance_double(ActiveSupport::Notifications::Event,
                            payload: { experiment_label: 'trstd-trdr', params: { 'experiment' => 'spoofed' } })

    expect(production_config.lograge.custom_options.call(event))
      .to include(experiment_label: 'trstd-trdr', params: {})
  end

  it 'tags request logs with the normalised request country' do
    country_tag = production_config.log_tags.second

    expect(country_tag.call(instance_double(ActionDispatch::Request,
                                            headers: { 'CloudFront-Viewer-Country' => 'GB' })))
      .to eq('request_country=gb')
  end

  it 'tags request logs with an unknown country when unavailable' do
    country_tag = production_config.log_tags.second

    expect(country_tag.call(instance_double(ActionDispatch::Request, headers: {})))
      .to eq('request_country=unknown')
  end

  it 'keeps the final production logger tagged' do
    expect(production_config.logger).to respond_to(:tagged)
  end
end
