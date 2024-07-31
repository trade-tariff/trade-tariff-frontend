require 'spec_helper'

RSpec.describe GreenLanes::FetchGoodsNomenclature do
  let(:params) do
    {
      commodity_code: '01020304',
      country_of_origin: 'GB',
      moving_date: '2024-01-01',
    }
  end

  let(:expected_response) do
    instance_double(GreenLanes::GoodsNomenclature, goods_nomenclature_item_id: '12345678')
  end

  before do
    allow(GreenLanes::GoodsNomenclature).to receive(:find).and_return(expected_response)
    allow(TradeTariffFrontend).to receive(:green_lanes_api_token).and_return('test_token')
  end

  describe '#call' do
    subject(:fetch_goods) { described_class.new(params).call }

    context 'with valid parameters' do
      it 'calls GoodsNomenclature.find with the correct arguments' do
        fetch_goods
        expect(GreenLanes::GoodsNomenclature).to have_received(:find).with(
          params[:commodity_code],
          {
            filter: {
              geographical_area_id: params[:country_of_origin],
              moving_date: params[:moving_date],
            },
            as_of: params[:moving_date],
          },
          authorization: TradeTariffFrontend.green_lanes_api_token,
        )
      end

      it 'returns the expected response' do
        expect(fetch_goods).to eq(expected_response)
      end
    end
  end
end
