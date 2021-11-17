require 'spec_helper'

RSpec.describe ClientBuilder do
  subject(:builder) { described_class.new(service) }

  let(:service) { :uk }

  describe '#call' do
    before do
      allow(Faraday).to receive(:new)
    end

    context 'when the service is uk' do
      let(:service) { :uk }

      it 'passes the correct configuration' do
        builder.call

        expect(Faraday).to have_received(:new).with('http://localhost:3018')
      end
    end

    context 'when the service is xi' do
      let(:service) { :xi }

      it 'passes the correct configuration' do
        builder.call

        expect(Faraday).to have_received(:new).with('http://localhost:3019')
      end
    end

    context 'when the services are not configured' do
      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:service_choices).and_return(nil)
      end

      it 'does not call Faraday' do
        builder.call

        expect(Faraday).not_to have_received(:new)
      end

      it { expect(builder.call).to be_nil }
    end
  end
end
