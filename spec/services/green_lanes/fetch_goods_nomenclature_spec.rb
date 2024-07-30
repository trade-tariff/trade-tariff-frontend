require 'spec_helper'

RSpec.describe GreenLanes::FetchGoodsNomenclature, type: :service do
  let(:params) do
    {
      commodity_code: '123456',
      country_of_origin: 'US',
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
    it 'fetches the goods nomenclature with the correct parameters', :aggregate_failures do
      service = described_class.new(params)
      result = service.call

      expect(GreenLanes::GoodsNomenclature).to have_received(:find).with(
        params[:commodity_code],
        {
          filter: {
            geographical_area_id: params[:country_of_origin],
            moving_date: params[:moving_date],
          },
          authorization: 'test_token',
        },
      )
      expect(result).to eq(expected_response)
    end
  end
end
