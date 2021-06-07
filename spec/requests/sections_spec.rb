require 'spec_helper'

describe 'Sections Index page', type: :request do
  context 'when requesting as HTML' do
    before do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('sections#index') do
          visit sections_path
        end
      end
    end

    it 'displays the first section as a link' do
      expect(page).to have_link 'Live animals; animal products'
    end

    it 'displays the second section as a link' do
      expect(page).to have_link 'Vehicles, aircraft'
    end

    it 'displays the third section as a link' do
      expect(page).to have_link 'Privacy'
    end
  end

  context 'when requesting as JSON' do
    context 'when requested with json format' do
      before do
        VCR.use_cassette('sections#index_api_json_format') do
          get '/sections.json'
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders direct API response' do
        expect(json).to be_kind_of Array
      end

      it 'renders the correct title for the first element' do
        expect(json.first['title']).to eq 'Live animals; animal products'
      end
    end

    context 'when requested with json HTTP Accept header' do
      before do
        VCR.use_cassette('sections#index_api_json_content_type') do
          get '/sections', headers: { 'HTTP_ACCEPT' => 'application/json' }
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders direct API response' do
        expect(json).to be_kind_of Array
      end

      it 'renders the correct title for the first element' do
        expect(json.first['title']).to eq 'Live animals; animal products'
      end
    end
  end
end

describe 'Section page', type: :request do
  context 'when requested as HTML' do
    before do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('sections#show') do
          visit section_path(1)
        end
      end
    end

    it 'displays the link to all sections' do
      expect(page).to have_link 'All sections',
                                href: '/'
    end

    it 'displays section name' do
      expect(page).to have_content 'Live animals; animal products'
    end

    it 'displays the first chapter in the section' do
      expect(page).to have_content 'Live animals'
    end

    it 'displays the second chapter in the section' do
      expect(page).to have_content 'Meat and edible meat offal'
    end
  end

  context 'when requested as JSON' do
    context 'when requested with json format' do
      before do
        VCR.use_cassette('sections#show_1_api_json_format') do
          get '/sections/1.json'
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders the correct title' do
        expect(json['title']).to eq 'Live animals; animal products'
      end

      it 'renders direct API response' do
        expect(json['chapters']).to be_kind_of Array
      end
    end

    context 'when requested with json HTTP Accept header' do
      before do
        VCR.use_cassette('sections#show_1_api_json_content_type') do
          get '/sections/1', headers: { 'HTTP_ACCEPT' => 'application/json' }
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders the correct title' do
        expect(json['title']).to eq 'Live animals; animal products'
      end

      it 'renders direct API response' do
        expect(json['chapters']).to be_kind_of Array
      end
    end
  end
end
