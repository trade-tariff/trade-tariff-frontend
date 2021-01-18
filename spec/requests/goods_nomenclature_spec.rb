require 'spec_helper'

describe 'Goods nomenclature API request', type: :request do
  context 'as JSON' do
    it 'renders direct API response as JSON' do
      VCR.use_cassette('goods_nomenclatures_heading_01_v2_api_json_format') do
        get '/api/v2/goods_nomenclatures/heading/0101.json'

        json = JSON.parse(response.body)

        expect(json['data']).to be_kind_of Array
        expect(json['data'].first).to be_kind_of Hash
        expect(json['data'].first).to have_key('id')
        expect(json['data'].first).to have_key('type')
        expect(json['data'].first).to have_key('attributes')
      end
    end
  end

  context 'as CSV' do
    it 'renders direct API response as CSV' do
      VCR.use_cassette('goods_nomenclatures_heading_01_v2_api_csv_format') do
        get '/api/v2/goods_nomenclatures/heading/0101.csv'

        expect(response.body).to include('SID,Goods Nomenclature Item ID,Indents,Description,Product Line Suffix,Href')
      end
    end
  end

  context 'scoped by date' do
    it 'renders direct API response scoped by date' do
      VCR.use_cassette('goods_nomenclatures_heading_01_as_of_date_v2_api_json_format') do
        get '/api/v2/goods_nomenclatures/heading/0101.json?as_of=1971-12-31'

        json = JSON.parse(response.body)

        expect(json['data']).to be_kind_of Array
        expect(json['data']).to eq([])
      end
    end
  end
end
