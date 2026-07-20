require 'spec_helper'

RSpec.describe Rails::Application::Configuration do
  it 'logs the trusted experiment label rather than request parameters' do
    production_config = described_class.new(Rails.root)
    production_config.lograge = ActiveSupport::OrderedOptions.new
    allow(Rails.application).to receive(:config).and_return(production_config)
    allow(Rails.application).to receive(:configure) { |&block| Rails.application.instance_eval(&block) }
    load Rails.root.join('config/environments/production.rb')

    event = instance_double(ActiveSupport::Notifications::Event,
                            payload: { experiment_label: 'trstd-trdr', params: { 'experiment' => 'spoofed' } })

    expect(production_config.lograge.custom_options.call(event))
      .to include(experiment_label: 'trstd-trdr', params: {})
  end
end
