require 'spec_helper'

RSpec.describe 'Chapter page', type: :request do
  context 'when requesting as HTML' do
    before do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('chapters#show') do
          visit chapter_path('01')
        end
      end
    end

    it 'displays the link to find commodity' do
      expect(page).to have_link 'Search',
                                href: '/find_commodity'
    end

    it 'displays the section as a link' do
      expect(page).to have_link 'Section I',
                                href: '/sections/1'
    end

    it 'displays the chapter classification' do
      expect(page).to have_content 'Live animals'
    end
  end

  context 'when requesting as JSON' do
    context 'when requested with json format' do
      before do
        VCR.use_cassette('chapters#show_01_api_json_format') do
          get '/chapters/01.json'
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders the correct item id' do
        expect(json['goods_nomenclature_item_id']).to eq '0100000000'
      end

      it 'renders direct API response' do
        expect(json['formatted_description']).to eq 'Live animals'
      end
    end

    context 'when requested with json HTTP Accept header' do
      before do
        VCR.use_cassette('chapters#show_01_api_json_content_type') do
          get '/chapters/01', headers: { 'HTTP_ACCEPT' => 'application/json' }
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders the correct item id' do
        expect(json['goods_nomenclature_item_id']).to eq '0100000000'
      end

      it 'renders direct API response' do
        expect(json['formatted_description']).to eq 'Live animals'
      end
    end
  end
end
