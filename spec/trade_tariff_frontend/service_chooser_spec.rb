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

  describe '.xi_host' do
    it { expect(described_class.xi_host).to eq('http://localhost:3019') }
  end

  describe '.uk_host' do
    it { expect(described_class.uk_host).to eq('http://localhost:3018') }
  end

  describe '.api_client' do
    before do
      Thread.current[:service_choice] = choice
    end

    context 'when the service choice is xi' do
      let(:choice) { 'xi' }

      it { expect(described_class.api_client).to eq(Rails.application.config.http_client_xi) }
      it { expect(described_class.api_client).to be_a(Faraday::Connection) }
    end

    context 'when the service choice is not xi' do
      let(:choice) { nil }

      it { expect(described_class.api_client).to eq(Rails.application.config.http_client_uk) }
      it { expect(described_class.api_client).to be_a(Faraday::Connection) }
    end
  end

  describe '.api_client_with_forwarding' do
    before do
      Thread.current[:service_choice] = choice
    end

    context 'when the service choice is xi' do
      let(:choice) { 'xi' }

      it { expect(described_class.api_client_with_forwarding).to eq(Rails.application.config.http_client_xi_forwarding) }
      it { expect(described_class.api_client_with_forwarding).to be_a(Faraday::Connection) }
    end

    context 'when the service choice is not xi' do
      let(:choice) { nil }

      it { expect(described_class.api_client_with_forwarding).to eq(Rails.application.config.http_client_uk_forwarding) }
      it { expect(described_class.api_client_with_forwarding).to be_a(Faraday::Connection) }
    end
  end

  describe '.currency' do
    context 'when the service is xi' do
      include_context 'with XI service'

      it 'returns the correct currency' do
        expect(described_class.currency).to eq('EUR')
      end
    end

    context 'when the service is uk' do
      include_context 'with UK service'

      it 'returns the correct currency' do
        expect(described_class.currency).to eq('GBP')
      end
    end

    context 'when the service is not set' do
      include_context 'with default service'

      it 'returns the correct currency' do
        expect(described_class.currency).to eq('GBP')
      end
    end
  end
end
