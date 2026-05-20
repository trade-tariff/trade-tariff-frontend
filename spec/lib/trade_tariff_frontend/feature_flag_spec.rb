require 'spec_helper'

RSpec.describe TradeTariffFrontend::FeatureFlag do
  subject(:feature_flag) { described_class }

  let(:ld_client) { Rails.application.config.launch_darkly_client }

  describe '.enabled?' do
    context 'when LaunchDarkly returns true for the flag' do
      before do
        allow(ld_client).to receive(:variation).with('green_lanes', anything, false).and_return(true)
      end

      it 'returns true' do
        expect(feature_flag.enabled?(:green_lanes)).to be true
      end
    end

    context 'when LaunchDarkly returns false for the flag' do
      before do
        allow(ld_client).to receive(:variation).with('green_lanes', anything, false).and_return(false)
      end

      it 'returns false' do
        expect(feature_flag.enabled?(:green_lanes)).to be false
      end
    end

    context 'with a string flag name' do
      before do
        allow(ld_client).to receive(:variation).with('green_lanes', anything, false).and_return(true)
      end

      it 'accepts strings as well as symbols' do
        expect(feature_flag.enabled?('green_lanes')).to be true
      end
    end

    context 'with an unknown flag name' do
      it 'raises UnknownFlagError' do
        expect { feature_flag.enabled?(:nonexistent_flag) }
          .to raise_error(TradeTariffFrontend::FeatureFlag::UnknownFlagError, /nonexistent_flag/)
      end
    end

    context 'when LaunchDarkly is offline (no SDK key configured)' do
      it 'returns the REGISTRY default for the flag' do
        # In test/dev without a LAUNCHDARKLY_SDK_KEY the client runs in offline
        # mode and variation() returns the default value we pass — the REGISTRY default.
        expect(feature_flag.enabled?(:green_lanes)).to be(
          TradeTariffFrontend::FeatureFlag::REGISTRY[:green_lanes],
        )
      end
    end

    context 'when building the evaluation context without a user_key' do
      it 'sends a single application context (not a multi-context) to LaunchDarkly' do
        expect(ld_client).to receive(:variation) do |_flag, context, _default|
          expect(context.multi_kind?).to be false
          expect(context.kind).to eq('application')
          false
        end

        feature_flag.enabled?(:green_lanes)
      end

      it 'passes the current service to LaunchDarkly' do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return('xi')

        expect(ld_client).to receive(:variation) do |_flag, context, _default|
          expect(context.get_value('service')).to eq('xi')
          false
        end

        feature_flag.enabled?(:green_lanes)
      end

      it 'passes the current environment to LaunchDarkly' do
        allow(TradeTariffFrontend).to receive(:environment).and_return('staging')

        expect(ld_client).to receive(:variation) do |_flag, context, _default|
          expect(context.get_value('environment')).to eq('staging')
          false
        end

        feature_flag.enabled?(:green_lanes)
      end
    end

    context 'when building the evaluation context with a user_key' do
      let(:user_key) { 'test-anonymous-uuid' }

      it 'sends a multi-context to LaunchDarkly' do
        expect(ld_client).to receive(:variation) do |_flag, context, _default|
          expect(context.multi_kind?).to be true
          false
        end

        feature_flag.enabled?(:green_lanes, user_key:)
      end

      it 'includes the application context in the multi-context' do
        expect(ld_client).to receive(:variation) do |_flag, context, _default|
          app = context.individual_context('application')
          expect(app).not_to be_nil
          expect(app.key).to eq('trade-tariff-frontend')
          false
        end

        feature_flag.enabled?(:green_lanes, user_key:)
      end

      it 'includes an anonymous user context carrying the key' do
        expect(ld_client).to receive(:variation) do |_flag, context, _default|
          user = context.individual_context('user')
          expect(user).not_to be_nil
          expect(user.key).to eq(user_key)
          expect(user.get_value('anonymous')).to be true
          false
        end

        feature_flag.enabled?(:green_lanes, user_key:)
      end
    end
  end

  describe '.disabled?' do
    it 'is the inverse of enabled?' do
      allow(ld_client).to receive(:variation).and_return(true)
      expect(feature_flag.disabled?(:green_lanes)).to be false
    end

    it 'raises UnknownFlagError for unknown flags' do
      expect { feature_flag.disabled?(:nonexistent_flag) }
        .to raise_error(TradeTariffFrontend::FeatureFlag::UnknownFlagError)
    end
  end

  describe 'REGISTRY' do
    it 'declares all flags with boolean defaults' do
      expect(TradeTariffFrontend::FeatureFlag::REGISTRY).to be_a(Hash)
      expect(TradeTariffFrontend::FeatureFlag::REGISTRY).not_to be_empty

      TradeTariffFrontend::FeatureFlag::REGISTRY.each do |flag, default|
        expect([true, false]).to include(default), "Expected #{flag} to have a boolean default"
      end
    end
  end
end
