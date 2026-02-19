RSpec.describe TariffChanges::TariffChange, type: :model do
  it 'sets and gets classification_description' do
    change = described_class.new
    change.classification_description = 'desc'
    expect(change.classification_description).to eq('desc')
  end

  it 'sets and gets goods_nomenclature_item_id' do
    change = described_class.new
    change.goods_nomenclature_item_id = '1234567890'
    expect(change.goods_nomenclature_item_id).to eq('1234567890')
  end

  it 'sets and gets date_of_effect' do
    change = described_class.new
    change.date_of_effect = Time.zone.today
    expect(change.date_of_effect).to eq(Time.zone.today)
  end

  describe '.download_file' do
    let(:token) { 'test_token' }
    let(:params) { { as_of: '2025-12-05' } }
    let(:response_body) { 'file content' }
    let(:response_content_type) { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }
    let(:api_client) { instance_double(Faraday::Connection) }

    before do
      allow(described_class).to receive(:api).and_return(api_client)
    end

    context 'when file is downloaded successfully' do
      before do
        faraday_response = instance_double(
          Faraday::Response,
          headers: { 'content-disposition' => 'attachment; filename="test_file.xlsx"', 'content-type' => response_content_type },
          body: response_body,
        )
        allow(api_client).to receive(:get).and_return(faraday_response)
      end

      it 'returns filename parsed from content-disposition' do
        result = described_class.download_file(token, params)
        expect(result[:filename]).to eq('test_file.xlsx')
      end

      it 'returns type' do
        result = described_class.download_file(token, params)
        expect(result[:type]).to eq(response_content_type)
      end

      it 'returns body' do
        result = described_class.download_file(token, params)
        expect(result[:body]).to eq(response_body)
      end
    end

    context 'when Content-Disposition header is missing' do
      before do
        faraday_response = instance_double(
          Faraday::Response,
          headers: { 'content-type' => response_content_type },
          body: response_body,
        )
        allow(api_client).to receive(:get).and_return(faraday_response)
      end

      it 'raises NoMethodError' do
        expect { described_class.download_file(token, params) }.to raise_error(NoMethodError)
      end
    end

    context 'when filename has RFC 5987 encoding' do
      before do
        faraday_response = instance_double(
          Faraday::Response,
          headers: { 'content-disposition' => "attachment; filename*=UTF-8''encoded_file.xlsx", 'content-type' => response_content_type },
          body: response_body,
        )
        allow(api_client).to receive(:get).and_return(faraday_response)
      end

      it 'returns nil for filename' do
        result = described_class.download_file(token, params)
        expect(result[:filename]).to be_nil
      end
    end
  end
end
