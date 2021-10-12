RSpec.describe ClientBuilder do
  subject(:builder) { described_class.new(service) }

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
  end
end
