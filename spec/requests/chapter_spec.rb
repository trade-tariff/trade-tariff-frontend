require 'spec_helper'

describe 'Chapter page', type: :request do
  context 'as HTML' do
    it 'displays chapter name and headings in the chapter' do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('chapters#show') do
          visit chapter_path('01')

          expect(page).to have_content 'Live animals'
          expect(page).to have_content 'Live bovine animals'
          expect(page).to have_content 'Live swine'
        end
      end
    end

    it 'displays chapter and heading codes for all headings in the chapter' do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('chapters#show') do
          visit chapter_path('01')

          expect(page).to have_selector '.chapter-code', text: '01', count: 7
          expect(page).to have_selector '.heading-code', text: '01', count: 1
          expect(page).to have_selector '.heading-code', text: '02', count: 1
          expect(page).to have_selector '.heading-code', text: '03', count: 1
          expect(page).to have_selector '.heading-code', text: '04', count: 1
          expect(page).to have_selector '.heading-code', text: '05', count: 1
          expect(page).to have_selector '.heading-code', text: '06', count: 1
        end
      end
    end
  end

  context 'as JSON' do
    context 'requested with json format' do
      it 'renders direct API response' do
        VCR.use_cassette('chapters#show_01_api_json_format') do
          get '/chapters/01.json'

          json = JSON.parse(response.body)

          expect(json['goods_nomenclature_item_id']).to eq '0100000000'
          expect(json['formatted_description']).to eq 'Live animals'
        end
      end
    end

    context 'requested with json HTTP Accept header' do
      it 'renders direct API response' do
        VCR.use_cassette('chapters#show_01_api_json_content_type') do
          get '/chapters/01', headers: { 'HTTP_ACCEPT' => 'application/json' }

          json = JSON.parse(response.body)

          expect(json['goods_nomenclature_item_id']).to eq '0100000000'
          expect(json['formatted_description']).to eq 'Live animals'
        end
      end
    end
  end
end
