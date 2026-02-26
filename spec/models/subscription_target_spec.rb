RSpec.describe SubscriptionTarget, type: :model do
  describe '.download_file' do
    let(:subscription_id) { 'subscription-id' }
    let(:token) { 'test_token' }
    let(:response_body) { 'file content' }
    let(:response_content_type) { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }
    let(:api_client) { instance_double(Faraday::Connection) }
    let(:path) { "/uk/user/subscriptions/#{subscription_id}/targets/download" }

    before do
      allow(described_class).to receive(:api).and_return(api_client)
      allow(described_class).to receive(:get)
    end

    context 'when file is downloaded successfully' do
      before do
        faraday_response = instance_double(
          Faraday::Response,
          headers: { 'content-disposition' => 'attachment; filename="my_watch_list.xlsx"', 'content-type' => response_content_type },
          body: response_body,
        )
        allow(api_client).to receive(:get).and_return(faraday_response)
      end

      it 'calls endpoints with auth headers', :aggregate_failures do
        described_class.download_file(subscription_id, token)

        expect(described_class).to have_received(:get).with(path, described_class.headers(token))
        expect(api_client).to have_received(:get).with(path, {}, described_class.headers(token))
      end

      it 'returns filename parsed from content-disposition' do
        result = described_class.download_file(subscription_id, token)

        expect(result[:filename]).to eq('my_watch_list.xlsx')
      end

      it 'returns type and body', :aggregate_failures do
        result = described_class.download_file(subscription_id, token)

        expect(result[:type]).to eq(response_content_type)
        expect(result[:body]).to eq(response_body)
      end
    end

    context 'when token is nil and not in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.download_file(subscription_id, nil)).to be_nil
      end
    end

    context 'when API returns unauthorized' do
      before do
        allow(api_client).to receive(:get).and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
      end

      it 'returns nil' do
        expect(described_class.download_file(subscription_id, token)).to be_nil
      end
    end
  end
end
