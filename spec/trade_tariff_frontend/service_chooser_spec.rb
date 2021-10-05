require 'spec_helper'

RSpec.describe TradeTariffFrontend::ServiceChooser do
  describe '.service_choices' do
    it 'returns a Hash of url options for the services' do
      expect(described_class.service_choices).to eq(
        'uk' => 'http://localhost:3018',
        'xi' => 'http://localhost:3019',
      )
    end
  end

  describe '.service_choice=' do
    it 'assigns the service choice to the current Thread' do
      expect { described_class.service_choice = 'xi' }
        .to change { Thread.current[:service_choice] }
        .from(nil)
        .to('xi')
    end
  end

  describe '.api_host' do
    before do
      Thread.current[:service_choice] = choice
    end

    context 'when the service choice does not have a corresponding url' do
      let(:choice) { 'foo' }

      it 'returns the default service choice url' do
        expect(described_class.api_host).to eq('http://localhost:3018')
      end
    end

    context 'when the service choice has a corresponding url' do
      let(:choice) { 'xi' }

      it 'returns the service choice url' do
        expect(described_class.api_host).to eq('http://localhost:3019')
      end
    end
  end

  describe '.with_source' do
    before do
      described_class.service_choice = :uk
    end

    it 'sets the source for the duration of the block' do
      described_class.with_source(:xi) do
        expect(described_class.service_choice).to eq('xi')
      end
    end

    it 'does not permanently change the source' do
      expect { described_class.with_source(:xi) {} }.not_to change(described_class, :service_choice).from(:uk)
    end
  end

  describe '.cache_with_service_choice' do
    let(:cache_key) { 'foo' }
    let(:options) { {} }

    before do
      described_class.service_choice = choice
      allow(Rails.cache).to receive(:fetch)
    end

    context 'when the service choice is nil' do
      let(:choice) { nil }

      it 'caches under the service default key prefix' do
        described_class.cache_with_service_choice(cache_key, options) {}

        expect(Rails.cache).to have_received(:fetch).with('uk.foo', options)
      end
    end

    context 'when the service choice is xi' do
      let(:choice) { 'xi' }

      it 'caches under the service default key prefix' do
        described_class.cache_with_service_choice(cache_key, options) {}

        expect(Rails.cache).to have_received(:fetch).with('xi.foo', options)
      end
    end
  end

  describe '.currency' do
    before do
      allow(described_class).to receive(:service_choice).and_return(choice)
    end

    context 'when the service is xi' do
      let(:choice) { 'xi' }

      it 'returns the correct currency' do
        expect(described_class.currency).to eq('EUR')
      end
    end

    context 'when the service is uk' do
      let(:choice) { 'uk' }

      it 'returns the correct currency' do
        expect(described_class.currency).to eq('GBP')
      end
    end

    context 'when the service is not set' do
      let(:choice) { nil }

      it 'returns the correct currency' do
        expect(described_class.currency).to eq('GBP')
      end
    end
  end
end
