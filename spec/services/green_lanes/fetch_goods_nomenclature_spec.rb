require 'spec_helper'

RSpec.describe GreenLanes::FetchGoodsNomenclature do
  describe '#call' do
    subject(:fetch_goods) { described_class.new(params).call }

    let(:params) do
      {
        commodity_code: '01020304',
        country_of_origin: 'GB',
        moving_date: '2024-01-01',
      }
    end

    let(:goods_nomenclature) do
      instance_double(GreenLanes::GoodsNomenclature, goods_nomenclature_item_id: '12345678')
    end

    before do
      allow(GreenLanes::GoodsNomenclature).to receive(:find).with(
        params[:commodity_code],
        {
          filter: {
            geographical_area_id: params[:country_of_origin],
            moving_date: params[:moving_date],
          },
          as_of: params[:moving_date],
        },
        {
          authorization: 'test_token',
        },
      ).and_return(goods_nomenclature)
      allow(TradeTariffFrontend).to receive(:green_lanes_api_token).and_return('test_token')
    end

    it { is_expected.to eq(goods_nomenclature) }
  end
end
