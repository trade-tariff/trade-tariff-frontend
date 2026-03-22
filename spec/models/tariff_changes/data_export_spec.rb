RSpec.describe DataExport, type: :model do
  let(:subscription_id) { 'b9f58768-971c-43ee-be92-77f49954e06c' }
  let(:export_id) { '5' }
  let(:token) { 'valid_token' }
  let(:headers) { { authorization: "Bearer #{token}" } }
  let(:api_client) { instance_double(Faraday::Connection) }

  before do
    allow(described_class).to receive(:api).and_return(api_client)
  end

  describe '.create!' do
    let(:attributes) { { export_type: 'ccwl' } }
    let(:created_export) { build(:data_export, resource_id: export_id, status: 'queued') }

    let(:response_body) do
      {
        'data' => {
          'id' => created_export.resource_id,
          'type' => 'data_export',
          'attributes' => {
            'status' => created_export.status,
          },
        },
      }
    end
    let(:faraday_response) { instance_double(Faraday::Response, body: response_body) }

    before do
      allow(api_client).to receive(:post).and_return(faraday_response)
    end

    context 'when token is nil and not in development' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.create!(subscription_id, nil, attributes)).to be_nil
      end

      it 'does not call api' do
        described_class.create!(subscription_id, nil, attributes)
        expect(api_client).not_to have_received(:post)
      end
    end

    context 'when token is provided' do
      it 'calls create endpoint with auth header and json body' do
        described_class.create!(subscription_id, token, attributes)

        expect(api_client).to have_received(:post).with(
          "/uk/user/subscriptions/#{subscription_id}/data_export",
          MultiJson.dump(data: { attributes: attributes }),
          hash_including(
            authorization: "Bearer #{token}",
            'Content-Type' => 'application/json',
          ),
        )
      end

      it 'returns a data export instance with parsed attributes', :aggregate_failures do
        result = described_class.create!(subscription_id, token, attributes)

        expect(result).to be_a(described_class)
        expect(result.resource_id).to eq(created_export.resource_id)
        expect(result.status).to eq(created_export.status)
      end
    end
  end

  describe '.find' do
    let(:opts) { { include: 'something' } }
    let(:found_export) { build(:data_export, :completed, resource_id: export_id) }

    let(:response_body) do
      {
        'data' => {
          'id' => found_export.resource_id,
          'type' => 'data_export',
          'attributes' => {
            'status' => found_export.status,
          },
        },
      }
    end
    let(:faraday_response) { instance_double(Faraday::Response, body: response_body) }

    before do
      allow(described_class).to receive(:headers).with(token).and_return(headers)
      allow(api_client).to receive(:get).and_return(faraday_response)
    end

    context 'when token is nil and not in development' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.find(subscription_id, export_id, nil, opts)).to be_nil
      end
    end

    context 'when token is provided' do
      it 'calls endpoint with subscription id and export id in path' do
        described_class.find(subscription_id, export_id, token, opts)

        expect(api_client).to have_received(:get).with(
          "/uk/user/subscriptions/#{subscription_id}/data_export/#{export_id}",
          opts,
          headers,
        )
      end

      it 'returns a data export instance', :aggregate_failures do
        result = described_class.find(subscription_id, export_id, token, opts)

        expect(result).to be_a(described_class)
        expect(result.resource_id).to eq(found_export.resource_id)
        expect(result.status).to eq(found_export.status)
      end
    end

    context 'when API returns unauthorized error' do
      before do
        allow(api_client).to receive(:get).and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
      end

      it 'returns nil' do
        expect(described_class.find(subscription_id, export_id, token, opts)).to be_nil
      end
    end
  end

  describe '.download_file' do
    let(:response_body) { 'binary-file-content' }
    let(:content_type) { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }
    let(:content_disposition) { 'attachment; filename="commodity_watch_list-your_codes_2026-03-09.xlsx"' }
    let(:faraday_response) do
      instance_double(
        Faraday::Response,
        body: response_body,
        headers: {
          'content-disposition' => content_disposition,
          'content-type' => content_type,
        },
      )
    end

    before do
      allow(described_class).to receive(:headers).with(token).and_return(headers)
      allow(api_client).to receive(:get).and_return(faraday_response)
    end

    context 'when token is nil and not in development' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.download_file(subscription_id, export_id, nil)).to be_nil
      end
    end

    context 'when token is provided' do
      it 'calls download endpoint with auth headers' do
        described_class.download_file(subscription_id, export_id, token)

        expect(api_client).to have_received(:get).with(
          "/uk/user/subscriptions/#{subscription_id}/data_export/#{export_id}/download",
          {},
          headers,
        )
      end

      it 'returns parsed file data hash', :aggregate_failures do
        result = described_class.download_file(subscription_id, export_id, token)

        expect(result[:body]).to eq(response_body)
        expect(result[:type]).to eq(content_type)
        expect(result[:filename]).to eq('commodity_watch_list-your_codes_2026-03-09.xlsx')
      end
    end

    context 'when API returns unauthorized error' do
      before do
        allow(api_client).to receive(:get).and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
      end

      it 'returns nil' do
        expect(described_class.download_file(subscription_id, export_id, token)).to be_nil
      end
    end
  end
end
