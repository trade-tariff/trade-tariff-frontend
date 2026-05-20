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
      before do
        allow(ld_client).to receive(:variation).and_return(false)
        feature_flag.enabled?(:green_lanes)
      end

      it 'does not build a multi-context' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| !ctx.multi_kind? },
          anything,
        )
      end

      it 'uses the application kind' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| ctx.kind == 'application' },
          anything,
        )
      end
    end

    context 'when the current service is xi' do
      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choice).and_return('xi')
        allow(ld_client).to receive(:variation).and_return(false)
        feature_flag.enabled?(:green_lanes)
      end

      it 'passes the xi service to LaunchDarkly in the context' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| ctx.get_value('service') == 'xi' },
          anything,
        )
      end
    end

    context 'when the environment is staging' do
      before do
        allow(TradeTariffFrontend).to receive(:environment).and_return('staging')
        allow(ld_client).to receive(:variation).and_return(false)
        feature_flag.enabled?(:green_lanes)
      end

      it 'passes the staging environment to LaunchDarkly in the context' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| ctx.get_value('environment') == 'staging' },
          anything,
        )
      end
    end

    context 'when building the evaluation context with a user_key' do
      let(:user_key) { 'test-anonymous-uuid' }

      before do
        allow(ld_client).to receive(:variation).and_return(false)
        feature_flag.enabled?(:green_lanes, user_key:)
      end

      it 'sends a multi-context to LaunchDarkly' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy(&:multi_kind?),
          anything,
        )
      end

      it 'includes the application context with the correct key' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| ctx.individual_context('application')&.key == 'trade-tariff-frontend' },
          anything,
        )
      end

      it 'includes a user context with the provided key' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| ctx.individual_context('user')&.key == user_key },
          anything,
        )
      end

      it 'marks the user context as anonymous' do
        expect(ld_client).to have_received(:variation).with(
          anything,
          satisfy { |ctx| ctx.individual_context('user')&.get_value('anonymous') == true },
          anything,
        )
      end
    end
  end

  describe '.disabled?' do
    before { allow(ld_client).to receive(:variation).and_return(true) }

    it 'is the inverse of enabled?' do
      expect(feature_flag.disabled?(:green_lanes)).to be false
    end

    it 'raises UnknownFlagError for unknown flags' do
      expect { feature_flag.disabled?(:nonexistent_flag) }
        .to raise_error(TradeTariffFrontend::FeatureFlag::UnknownFlagError)
    end
  end

  describe 'REGISTRY' do
    it 'is a non-empty hash' do
      expect(TradeTariffFrontend::FeatureFlag::REGISTRY).to be_a(Hash).and(be_present)
    end

    it 'has boolean defaults for every flag' do
      non_boolean = TradeTariffFrontend::FeatureFlag::REGISTRY.reject { |_, v| [true, false].include?(v) }
      expect(non_boolean).to be_empty
    end
  end
end
