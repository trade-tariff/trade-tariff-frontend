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

    it 'displays the link to all sections' do
      expect(page).to have_link 'All sections',
                                href: '/sections'
    end

    it 'displays the section as a link' do
      expect(page).to have_link 'Section I: Live animals; animal products',
                                href: '/sections/1'
    end

    it 'displays the chapter name' do
      expect(page).to have_content 'Live animals'
    end

    it 'displays the second heading in the chapter as a link' do
      expect(page).to have_link 'Live bovine animals'
    end

    it 'displays the third heading in the chapter as a link' do
      expect(page).to have_link 'Live swine'
    end

    it 'displays chapter codes for all headings in the chapter' do
      expect(page).to have_selector '.chapter-code', text: '01', count: 8
    end

    it 'displays heading codes for the first heading in the chapter' do
      expect(page).to have_selector '.heading-code', text: '01', count: 1
    end

    it 'displays heading codes for the second heading in the chapter' do
      expect(page).to have_selector '.heading-code', text: '02', count: 1
    end

    it 'displays heading codes for the third heading in the chapter' do
      expect(page).to have_selector '.heading-code', text: '03', count: 1
    end

    it 'displays heading codes for the fourth heading in the chapter' do
      expect(page).to have_selector '.heading-code', text: '04', count: 1
    end

    it 'displays heading codes for the fifth heading in the chapter' do
      expect(page).to have_selector '.heading-code', text: '05', count: 1
    end

    it 'displays heading codes for the sixth heading in the chapter' do
      expect(page).to have_selector '.heading-code', text: '06', count: 1
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
