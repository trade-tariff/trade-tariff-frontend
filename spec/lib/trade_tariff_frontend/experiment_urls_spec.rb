require 'spec_helper'

RSpec.describe TradeTariffFrontend::ExperimentUrls do
  subject(:registry) { described_class.new(config, registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi]) }

  let(:entry) do
    {
      path: '/trusted-trader-guided-search',
      feature: 'interactive_search',
      starts_on: '2026-07-27',
      ends_on: '2026-07-31',
      timezone: 'Europe/London',
      redirect: '/find_commodity',
      service: 'uk',
      instrumentation_label: 'trstd-trdr',
    }
  end
  let(:config) { { trusted_trader_guided_search: entry } }

  it 'parses immutable entries and looks them up by key or token', :aggregate_failures do
    experiment = registry.fetch(:trusted_trader_guided_search)
    expect(experiment).to have_attributes(key: 'trusted_trader_guided_search', path: entry[:path],
                                          feature_name: entry[:feature], starts_on: Date.new(2026, 7, 27),
                                          ends_on: Date.new(2026, 7, 31), timezone: entry[:timezone],
                                          redirect_path: entry[:redirect], service: 'uk', instrumentation_label: 'trstd-trdr')
    expect(experiment.enrollment_token).to match(/\Atrusted_trader_guided_search:[a-f0-9]{16}\z/)
    expect(registry.find_by_enrollment_token(experiment.enrollment_token)).to equal(experiment)
    expect(registry.find_by_enrollment_token('stale')).to be_nil
    changed = described_class.new({ trusted_trader_guided_search: entry.merge(redirect: '/changed') },
                                  registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi])
    expect(changed.first.enrollment_token).not_to eq(experiment.enrollment_token)
    expect([registry, experiment, experiment.path, experiment.timezone]).to all(be_frozen)
  end

  it 'uses inclusive London calendar dates and the configured service' do
    experiment = registry.first
    expectations = {
      [Time.utc(2026, 7, 26, 22, 59, 59), 'uk'] => :not_started,
      [Time.utc(2026, 7, 26, 23), 'uk'] => :active,
      [Time.utc(2026, 7, 31, 22, 59, 59), 'uk'] => :active,
      [Time.utc(2026, 7, 31, 23), 'uk'] => :expired,
      [Time.utc(2026, 7, 28, 12), 'xi'] => :wrong_service,
    }
    expectations.each { |(time, service), state| expect(experiment.state_at(time, service_name: service)).to eq(state) }
  end

  it 'rejects invalid boot configuration with context' do
    invalid = {
      path: 'relative',
      feature: 'webchat',
      starts_on: 'bad',
      ends_on: '2026-07-26',
      timezone: 'London-ish',
      redirect: 'external',
      service: 'xi',
      instrumentation_label: 'Bad_Label',
    }
    invalid.each do |field, value|
      changed = { trusted_trader_guided_search: entry.merge(field => value) }
      expect { described_class.new(changed, registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi]) }
        .to raise_error(described_class::ConfigurationError, /entry trusted_trader_guided_search field #{field}/)
    end
  end

  it 'rejects missing fields, duplicate routes and redirect loops', :aggregate_failures do
    expect { described_class.new({ ('a' * 65) => entry }, registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi]) }
      .to raise_error(described_class::ConfigurationError, /field key must be at most 64/)
    expect { described_class.new({ experiment: entry.except(:path) }, registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi]) }
      .to raise_error(described_class::ConfigurationError, /field path is required/)
    duplicate = { first: entry, second: entry.merge(instrumentation_label: 'second') }
    expect { described_class.new(duplicate, registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi]) }
      .to raise_error(described_class::ConfigurationError, /field path duplicates/)
    looped = { experiment: entry.merge(redirect: entry[:path]) }
    expect { described_class.new(looped, registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi]) }
      .to raise_error(described_class::ConfigurationError, /redirect must not target an experiment URL/)
  end
end
