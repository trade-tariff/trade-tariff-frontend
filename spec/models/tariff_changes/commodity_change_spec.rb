require 'spec_helper'

RSpec.describe TariffChanges::CommodityChange do
  let(:token) { 'valid_token' }
  let(:params) { {} }
  let(:collection_path) { '/uk/user/commodity_changes' }
  let(:headers) { { authorization: "Bearer #{token}" } }

  describe '.all' do
    context 'when token is provided' do
      let(:collection_data) do
        [
          build(:commodity_change),
          build(:commodity_change, description: 'Changes to classification'),
        ]
      end

      before do
        allow(described_class).to receive_messages(
          collection: collection_data,
          headers: headers,
        )
      end

      it 'calls collection with correct parameters' do
        described_class.all(token, params)

        expect(described_class).to have_received(:collection)
          .with(collection_path, params, headers)
      end

      it 'returns an array' do
        result = described_class.all(token, params)
        expect(result).to be_an(Array)
      end
    end

    context 'when token is nil and not in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns empty array' do
        result = described_class.all(nil, params)
        expect(result).to eq([])
      end

      it 'does not call collection method' do
        allow(described_class).to receive(:collection)
        described_class.all(nil, params)
        expect(described_class).not_to have_received(:collection)
      end
    end

    context 'when token is nil but in development environment' do
      let(:collection_data) { [] }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(described_class).to receive_messages(
          collection: collection_data,
          headers: headers,
        )
      end

      it 'calls collection method' do
        described_class.all(nil, params)
        expect(described_class).to have_received(:collection)
      end
    end

    context 'when Faraday::UnauthorizedError is raised' do
      before do
        allow(described_class).to receive(:collection).and_raise(Faraday::UnauthorizedError)
        allow(described_class).to receive(:headers).and_return(headers)
      end

      it 'returns empty array' do
        result = described_class.all(token, params)
        expect(result).to eq([])
      end
    end

    context 'with date parameter' do
      let(:date) { Date.current }
      let(:params) { { as_of: date } }
      let(:collection_data) { [] }

      before do
        allow(described_class).to receive_messages(
          collection: collection_data,
          headers: headers,
        )
      end

      it 'passes date parameter to collection' do
        described_class.all(token, params)
        expect(described_class).to have_received(:collection)
          .with(collection_path, params, headers)
      end
    end
  end
end
