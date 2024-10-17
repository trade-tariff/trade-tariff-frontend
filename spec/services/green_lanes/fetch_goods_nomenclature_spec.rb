require 'spec_helper'

RSpec.describe GreenLanes::FetchGoodsNomenclature, vcr: { cassette_name: 'green_lanes/get_goods_nomenclatures' } do
  describe '#call' do
    subject(:fetch_goods) { described_class.new(params).call }

    describe 'retuns the goods' do
      let(:params) do
        {
          commodity_code: '4114109000',
          country_of_origin: 'PT',
          moving_date: '2024-01-01',
        }
      end

      it { expect(fetch_goods.goods_nomenclature_item_id).to eq('4114109000') }

      it { expect(fetch_goods.description).to eq('Of other animals') }
    end
  end
end
