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
                                          feature_names: [entry[:feature]], starts_on: Date.new(2026, 7, 27),
                                          ends_on: Date.new(2026, 7, 31), timezone: entry[:timezone],
                                          redirect_path: entry[:redirect], service: 'uk', instrumentation_label: 'trstd-trdr')
    expect(experiment.enrollment_token).to eq('trusted_trader_guided_search:3e5d8e2314add509')
    expect(registry.find_by_enrollment_token(experiment.enrollment_token)).to equal(experiment)
    expect(registry.find_by_enrollment_token('stale')).to be_nil
    changed = described_class.new({ trusted_trader_guided_search: entry.merge(redirect: '/changed') },
                                  registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi])
    expect(changed.first.enrollment_token).not_to eq(experiment.enrollment_token)
    expect([registry, experiment, experiment.path, experiment.timezone]).to all(be_frozen)
  end

  %w[uk xi].each do |service|
    it "accepts a supported opt-in flag on #{service}", :aggregate_failures do
      entry.merge!(feature: 'hybrid_search', service:)

      expect(registry.first.feature_names).to eq(%w[hybrid_search])
      expect(registry.first.service).to eq(service)
    end
  end

  context 'with multiple features' do
    let(:features) { %w[interactive_search enhanced_guided_search_loading] }
    let(:config) { { trusted_trader_guided_search: entry.except(:feature).merge(features:) } }

    it 'exposes an immutable list of opt-ins', :aggregate_failures do
      expect(registry.first.feature_names).to eq(features)
      expect(registry.first.feature_names).to be_frozen
      expect(registry.first.feature_names).to all(be_frozen)
    end

    it 'changes the token when membership changes, but not when the list is reordered', :aggregate_failures do
      reordered = described_class.new({ trusted_trader_guided_search: config.values.first.merge(features: features.reverse) },
                                      registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi])
      reduced = described_class.new({ trusted_trader_guided_search: config.values.first.merge(features: [features.first]) },
                                    registered_flags: TradeTariffFrontend::Config.registered_flags, service_names: %w[uk xi])

      expect(reordered.first.enrollment_token).to eq(registry.first.enrollment_token)
      expect(reduced.first.enrollment_token).not_to eq(registry.first.enrollment_token)
      expect(registry.find_by_enrollment_token(reduced.first.enrollment_token)).to be_nil
      expect(registry.find_by_enrollment_token('trusted_trader_guided_search:3e5d8e2314add509')).to be_nil
    end

    [nil,
     [],
     'interactive_search',
     [''],
     [false],
     %w[interactive_search interactive_search],
     %w[interactive_search unknown],
     %w[interactive_search webchat]].each do |invalid_features|
      context "with invalid features #{invalid_features.inspect}" do
        let(:features) { invalid_features }

        it 'rejects the list at boot with field context' do
          expect { registry }.to raise_error(described_class::ConfigurationError, /entry trusted_trader_guided_search field features/)
        end
      end
    end

    it 'rejects conflicting singular and plural fields, even when the singular field is null' do
      config[:trusted_trader_guided_search][:feature] = nil

      expect { registry }.to raise_error(described_class::ConfigurationError, /field features must not be combined with feature/)
    end

    it 'checks the configured service for every feature' do
      config[:trusted_trader_guided_search].merge!(features: %w[hybrid_search interactive_search], service: 'xi')

      expect { registry }.to raise_error(described_class::ConfigurationError, /field service is not supported by feature interactive_search/)
    end
  end

  it 'requires a singular feature when no list is supplied' do
    config[:trusted_trader_guided_search].delete(:feature)

    expect { registry }.to raise_error(described_class::ConfigurationError, /field feature is required/)
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

  context 'without an end date' do
    let(:config) { { trusted_trader_guided_search: entry.except(:ends_on) } }

    it 'keeps the start and service boundaries', :aggregate_failures do
      experiment = registry.first

      expect(experiment.ends_on).to be_nil
      expect(experiment.state_at(Time.utc(2026, 7, 26, 22, 59, 59), service_name: 'uk')).to eq(:not_started)
      expect(experiment.state_at(Time.utc(2026, 7, 26, 23), service_name: 'uk')).to eq(:active)
      expect(experiment.state_at(Time.utc(2036, 7, 27), service_name: 'uk')).to eq(:active)
      expect(experiment.state_at(Time.utc(2036, 7, 27), service_name: 'xi')).to eq(:wrong_service)
    end

    it 'does not expire the enrolment' do
      expect(registry.first.expired_at?(Time.utc(2036, 7, 27))).to be(false)
    end
  end

  context 'with a null end date' do
    let(:config) { { trusted_trader_guided_search: entry.merge(ends_on: nil) } }

    it 'does not expire the enrolment' do
      expect(registry.first.expired_at?(Time.utc(2036, 7, 27))).to be(false)
    end
  end

  ['', 'invalid', false].each do |ends_on|
    context "with an invalid end date of #{ends_on.inspect}" do
      let(:config) { { trusted_trader_guided_search: entry.merge(ends_on:) } }

      it 'rejects the supplied date' do
        expect { registry }.to raise_error(described_class::ConfigurationError, /field ends_on/)
      end
    end
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
